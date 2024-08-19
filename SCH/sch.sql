set scan off
create or replace PACKAGE SCH  IS

    PROCEDURE MAIN;

    PROCEDURE JOB_QUARTER ( PRM_CHECK VARCHAR2 DEFAULT NULL );

    procedure alert_online (p_id       in out number,
                            p_bloco			  varchar2 default null,
                            p_inicio 		  date     default null,
                            p_fim			  date     default null,
                            p_parametro		  varchar2 default null,
                            p_status 		  varchar2 default null,
                            p_obs	          varchar2 default null,
                            p_st_notify       varchar2 default 'REGISTRO',
                            p_mail_notify     varchar2 default 'N',
                            p_pipe_tabelas    varchar2 default null ) ; 

    procedure reg_online_usuario ; 

    function ret_var  ( prm_variavel   varchar2 default null, 
                        prm_usuario    varchar2 default 'DWU' ) return varchar2 ;

END SCH;
/
create or replace package body  SCH  is

procedure main as

    ws_hora         varchar2(2);
    ws_quarter      varchar2(2);
    ws_auto         char(1);

    ws_req          varchar2(200);
    ws_res          varchar2(800);
    ws_ultimo       date;
    ws_atual        date;

    ws_count        number := 0;

    ws_conteudo     varchar2(200);

begin

    ws_hora    := to_char(sysdate,'HH24');
    ws_quarter := to_char(sysdate,'MI');

    --verifica a versão do oracle se suporta o envio de email
    select instr(upper(banner), 'EXPRESS') into ws_count from v$version where rownum = 1;

    if ws_count = 0 then
        --comunicação com email
        begin    
            fun.execute_now('com.reportExec', 'N');
        exception when others then
            insert into bi_log_sistema values (sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SCH', 'SYS', 'ERRO');
            commit;
        end;

    end if;

    fun.execute_now('etl.exec_schdl', 'N');

    select count(*) into ws_count from bi_auto_update where status = 'U';

    if ws_count = 0 then

        if instr(upd.validar(fun.ret_var('CLIENTE')), 'S') > 0 then

            --auto update as 11:00
            if ws_hora = nvl(fun.ret_var('AUTO_UPDATE'), '11') and ws_quarter = '00' then

                --loop dos tipos de auto_update
                for i in(select ultimo_update, auto, tipo from bi_auto_update where auto = 'S' order by decode(tipo, 'FUN', 'Z', tipo) desc) loop

                    --000000026 cristal
                    ws_req := 'http://update.upquery.com/update/dwu.get_padroes?prm_tipo=CHECK_UPDATE&prm_chave='||i.tipo;
                    ws_ultimo := Utl_Http.Request(ws_req);

                    if ws_ultimo > nvl(i.ultimo_update, sysdate-2) then

                        insert into bi_log_sistema values (sysdate, 'AUTO ATUALIZANDO '||i.tipo||'', 'SYS', 'EVENTO');
                        commit;

                        if i.tipo = 'PADROES' then
                            upd.padroes;
                        end if;

                        if i.tipo in ('AUX', 'BRO', 'COM', 'CORE', 'FCL', 'FUN', 'GBL', 'OBJ', 'IMP', 'UPLOAD', 'UPQUERY', 'UP_REL') then
                            upd.packages(i.tipo);
                        end if;

                        if i.tipo in ('CSS', 'JS') then
                            upd.documentos(i.tipo);
                        end if;

                    end if;

                end loop;

            end if;

        end if;

    end if;

    if mod(to_number(ws_quarter), 15) = 0 and nvl(fun.ret_var('JOB'), 'S') = 'S' then -- COD #103

        select nvl(max(conteudo),'N') into ws_conteudo from var_conteudo where variavel = 'BLOQ_QUARTER';

        if  nvl(ws_conteudo,'N')='S' then
            
            --htp.p('JOB_QUARTER bloqueado.');
            --insert into err_txt values ('bloq_quarter = s ');
            insert into bi_log_sistema values (sysdate,'JOB QUARTER BLOQUEADO','DWU','EVENTO');
            commit;
        
        else

            fun.execute_now('sch.job_quarter', 'N');
            --sch.job_quarter;
        end if;
        
    end if;

    delete from bi_token where dt_envio < sysdate-1 and status <> 'D';
    commit;

exception when others then
    insert into bi_log_sistema values (sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SCH', 'SYS', 'ERRO');
    commit;
end main;

procedure job_quarter ( prm_check varchar2 default null ) as 

    cursor crs_log_eventos (p_tipo varchar2) is
        select usuario, count(*) acessos
          from log_eventos
         where data_evento >= trunc(sysdate-1) 
           and data_evento <  trunc(sysdate) 
           and tipo        = p_tipo 
         group by usuario;

    ws_reg_online       varchar2(100);
    ws_noact            exception;
    ws_timeout          exception;
    ws_erro             varchar2(4000);
    ws_vartemp          varchar2(100);
    ws_try              number;
    ws_check            number     := 0;

    ws_owner      varchar2(90);
    ws_name       varchar2(90);
    ws_line       number;
    ws_caller     varchar2(90);


    PROCEDURE NESTED_REG_ONLINE ( prm_tipo     varchar2 default null,
                                  prm_evento   varchar2 default null,
                                  prm_status   varchar2 default null,
                                  prm_usuario  varchar2 default null,
                                  prm_qtde     varchar2 default null ) as

                cursor crs_pendings is
                    select   DT_REGISTRO, COMMAND, ROWID ID_LINHA
                    from     PENDING_REGS
                    where    STATUS='P'
                    order by dt_registro desc;

        ws_pendings        crs_pendings%rowtype;

        ws_count        number;
        ws_pending      number;
        ws_string       varchar2(4000);
        ws_command      varchar2(4000);
        ws_error_count  number := 0;
        ws_error        varchar2(200);
        ws_address      varchar2(200);
        ws_usuario      varchar2(80);
        ws_param        varchar2(1000);         

    begin

        ws_usuario := user;

        ws_count := 0;

        select NVL((TRUNC(SYSDATE)-MIN(TRUNC(DT_REGISTRO))),0) into ws_pending
        from   PENDING_REGS
        where  STATUS='P';

        if  ws_pending > 30 then
            update OBJECT_LOCATION set POSX='11px'   where OWNER='DWU' and
                                                        NAVEGADOR='DEFAULT' and
                                                        OBJECT_ID='CONFIG';
            commit;
        end if;

        open crs_pendings;
            loop
                fetch crs_pendings into ws_pendings;
                exit when crs_pendings%notfound;

                begin
                    ws_string := utl_http.request(ws_pendings.command);
                    begin
                        update PENDING_REGS set status = 'K' where rowid=ws_pendings.id_linha;
                        commit;
                        ws_count := ws_count+1;
                    exception
                        when others then
                            insert into log_eventos values(sysdate, '[RO]-FALHA UNSET PENDING!', ws_usuario, 'REG_OFF', 'OFF', '01');
                            commit;
                    end;
                exception
                    when others then
                        insert into log_eventos values(sysdate, '[RO]-FALHA UNSET PENDING!', ws_usuario, 'REG_OFF', 'OFF', '01');
                        commit;
                end;
            end loop;
        close crs_pendings;

        if  ws_count > 0 then
            insert into log_eventos values(sysdate, '[RO]-OFFLINE REGS['||ws_count||']!', ws_usuario, 'REG_OFF', 'OFF', '01');
            commit;
        end if;

        if  prm_tipo='001' then
            begin
                ws_command := 'http://'||SCH.ret_var('DOMINIO_REG')||'/update/dwu.renew?prm_par=TIPO|001|CLIENTE|'||SCH.ret_var('CLIENTE')||'|DATA|'||to_char(sysdate,'ddmmyyhh24mi')||'|EVENTO|'||prm_evento||'|STATUS|'||prm_status;
                begin
                    ws_string  := utl_http.request(ws_command);
                exception
                    when others then
                        insert into PENDING_REGS values (sysdate,ws_command,'P');
                        commit;
                end;
            end;
        end if;

        if prm_tipo='002' then
            begin
                ws_command := 'http://'||SCH.ret_var('DOMINIO_REG')||'/update/dwu.renew?prm_par=TIPO|002|CLIENTE|'||SCH.ret_var('CLIENTE')||'|DATA|'||to_char(trunc(sysdate-1),'ddmmyyhh24mi')||'|USUARIO|'||prm_usuario||'|ACESSOS|'||prm_status;
                begin
                    ws_string  := utl_http.request(ws_command);
                exception
                    when others then
                        insert into PENDING_REGS values (sysdate,ws_command,'P');
                        commit;
                end;
            end;
        end if;

        if prm_tipo='003' then
            begin
                ws_command := 'http://'||SCH.ret_var('DOMINIO_REG')||'/update/dwu.renew?prm_par=TIPO|003|CLIENTE|'||SCH.ret_var('CLIENTE')||'|DATA|'||to_char(sysdate,'ddmmyyhh24mi')||'|EVENTO|'||prm_evento||'|STATUS|'||prm_status;
                begin
                    ws_string := utl_http.request(ws_command);
                exception
                    when others then
                        insert into PENDING_REGS values (sysdate,ws_command,'P');
                        commit;
                end;
                if trim(ws_string)='LOCK_SYS' then
                    update OBJECT_LOCATION set POSX='11px' where OWNER='DWU' and
                        NAVEGADOR='DEFAULT' and OBJECT_ID='CONFIG';
                    commit;
                end if;
                if trim(ws_string)='UNLOCK_SYS' then
                    update OBJECT_LOCATION set POSX='12px' where OWNER='DWU' and
                    NAVEGADOR='DEFAULT' and
                    OBJECT_ID='CONFIG';
                    commit;
                end if;
            end;
        end if;

        if  prm_tipo='004' then
            begin
                ws_command := 'http://'||SCH.ret_var('DOMINIO_REG')||'/update/dwu.renew?prm_par=TIPO|004|CLIENTE|'||SCH.ret_var('CLIENTE')||'|DATA|'||to_char(sysdate,'ddmmyyhh24mi')||'|DS_EVENTO|'||prm_evento||'|STATUS|'||prm_status;
                begin
                    ws_string  := utl_http.request(ws_command);
                exception
                    when others then
                        insert into PENDING_REGS values (sysdate,ws_command,'P');
                        commit;
                end;
            end;
        end if;

        if  prm_tipo='005' then
            begin
                ws_command := 'http://'||SCH.ret_var('DOMINIO_REG')||'/update/dwu.renew?prm_par=TIPO|005|CLIENTE|'||SCH.ret_var('CLIENTE')||'|DATA|'||to_char(trunc(sysdate-1),'ddmmyyhh24mi')||'|USUARIO|'||prm_usuario||'|ACESSOS|'||prm_status||'|QTDE|'||prm_qtde;
                begin
                    ws_string  := utl_http.request(ws_command);
                exception
                    when others then
                        insert into PENDING_REGS values (sysdate,ws_command,'P');
                        commit;
                end;
            end;
        end if;


        -- Registro de alteração de usuário     
        if prm_tipo='012' then

            ws_param := null;     -- Se não existir registro na tabela USUARIOS vai levar os campos nulos com situação/status = EXCLUIDO 
            select '|NM_COMPLETO|'||rawtohex(max(USU_COMPLETO))||'|DS_EMAIL|'||rawtohex(max(USU_EMAIL))||'|NR_TELEFONE|'||rawtohex(max(USU_NUMBER))|| '|ID_SITUACAO|'||rawtohex(nvl(max(STATUS),'EXCLUIDO') )||'|DT_ULTIMA_VALIDACAO|'||rawtohex(TO_CHAR(max(NULL),'DD/MM/YYYY HH24:MI:SS')) into ws_param          
              from usuarios
             where usu_nome = prm_usuario ; 

            if ws_param is not null then 
                ws_command := 'http://'||sch.ret_var('DOMINIO_REG')||'/update/dwu.renew?prm_par=TIPO|012|CLIENTE|'||sch.ret_var('CLIENTE')||'|DATA|'||to_char(trunc(sysdate-1),'ddmmyyhh24mi')||'|USUARIO|'||prm_usuario||ws_param;
                begin
                    ws_string  := utl_http.request(ws_command);
                exception
                    when others then
                        insert into PENDING_REGS values (sysdate,ws_command,'P');
                        commit;
                end;         
            end if;
        end if;


        ws_string := TRIM(replace(ws_string,chr(10),''));

        if  ws_string not in ('OK REGISTRADO','UNLOCK_SYS','LOCK_SYS') then
            insert into log_eventos values(sysdate, '[RO]-FALHA REG.ONLINE SERVIDOR!', user, 'REG_OFF', 'OFF', '01');
            insert into bi_log_sistema values(sysdate, substr('[RO]-FALHA REG.ONLINE SERVIDOR ('||prm_tipo||'): '||ws_string,1,2000), ws_usuario, 'ERRO');            
            commit;
        end if;

    exception when others then
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - REG_ONLINE', ws_usuario, 'ERRO');
        update OBJECT_LOCATION set POSX='11px' where OWNER='DWU' and NAVEGADOR='DEFAULT' and OBJECT_ID='CONFIG';
        commit;
    end NESTED_REG_ONLINE;

    procedure NESTED_STATUS_PROCESS ( prm_cd_processo varchar2,
                                      prm_ds_processo varchar2,
                                      prm_comando     varchar2) as

      ws_check_run      number := 0;
      ws_saida          varchar2(40);

    begin

        select count(*) into ws_check_run
        from   RUNNING_PROCESS
        where  cd_processo = prm_cd_processo and
                last_status = 'RUNNING';

        if  prm_comando = 'START' then
            if  ws_check_run>0 then
                ws_saida := 'RUNNING';
            else
                insert into RUNNING_PROCESS values (prm_cd_processo,prm_ds_processo,sysdate,null,'RUNNING');
                commit;
                NESTED_REG_ONLINE('004',prm_ds_processo,prm_comando);
                ws_saida := 'OK';
            end if;
        else
            if  prm_comando = 'ERRO' then
                if  ws_check_run=0 then
                    ws_saida := 'NO_SENSE';
                else
                    update RUNNING_PROCESS set dt_final    = sysdate,
                                                last_status = 'ERRO'
                    where  cd_processo = prm_cd_processo and
                            last_status = 'RUNNING';
                    commit;
                    NESTED_REG_ONLINE('004',prm_ds_processo,prm_comando);
                    ws_saida := 'OK';
                end if;
            else
                if  ws_check_run=0 then
                    ws_saida := 'NO_SENSE';
                else
                    update RUNNING_PROCESS set dt_final    = sysdate,
                                                last_status = 'END'
                    where  cd_processo = prm_cd_processo and
                            last_status = 'RUNNING';
                    commit;
                    NESTED_REG_ONLINE('004',prm_ds_processo,prm_comando);
                    ws_saida := 'OK';
                end if;
            END IF;
        end if;

    end NESTED_STATUS_PROCESS;

BEGIN

--if to_number(to_char(sysdate, 'HH24')) > 3 and to_number(to_char(sysdate, 'HH24')) < 22 then

    WS_TRY   := 70;
    WS_CHECK := 1;
    LOOP
    EXIT WHEN WS_CHECK=0;

        SELECT COUNT(*) INTO WS_CHECK
        FROM   RUNNING_PROCESS
        WHERE LAST_STATUS='RUNNING';
        WS_TRY := WS_TRY - 1;
        WS_TRY := WS_TRY - 1;
        IF  WS_TRY=0 AND WS_CHECK<>0 THEN
            RAISE WS_TIMEOUT;
        END IF;

        IF  WS_CHECK <> 0 THEN
            DBMS_LOCK.SLEEP(15);
        END IF;
    END LOOP;

    WS_TRY   := 70;
    WS_CHECK := 1;
    LOOP
    EXIT WHEN WS_CHECK=0;

        SELECT COUNT(*) INTO WS_CHECK
        FROM   RUNNING_PROCESS
        WHERE LAST_STATUS='RUNNING';
        WS_TRY := WS_TRY - 1;
        IF  WS_TRY=0 AND WS_CHECK<>0 THEN
            RAISE WS_TIMEOUT;
        END IF;

        IF  WS_CHECK<>0 THEN
            DBMS_LOCK.SLEEP(15);
        END IF;
    END LOOP;

    INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-NINICIO PROCESSO!' , USER , 'CALCULO' , 'OK', '0');
    COMMIT;

    BEGIN
        NESTED_STATUS_PROCESS('000006','JOB_QUARTER','START');
    EXCEPTION
        WHEN OTHERS THEN
            INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-PROCESSO SEM REGISTRO!' , USER , 'CALCULO' , 'OK', '0');
            COMMIT;
    END;

    INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-RUNNING PROCESS!' , USER , 'CALCULO' , 'OK', '0');
    COMMIT;

    UPDATE VAR_CONTEUDO SET CONTEUDO=TO_CHAR(SYSDATE,'dd/mon/yyyy','NLS_DATE_LANGUAGE = AMERICAN')
        WHERE VARIAVEL = 'DATA_ATUAL';
    COMMIT;


    EXEC_QUARTER;

    IF  TRUNC(SYSDATE) <> TO_DATE(SCH.ret_var('DIA_TROCA'),'dd/mon/yyyy','NLS_DATE_LANGUAGE = AMERICAN') THEN
        INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-Novo Dia Início!' , USER , 'CALCULO' , 'OK', '0');
        COMMIT;

        /** 
        FOR AC_USER IN CRS_USUARIOS LOOP
            EXIT WHEN CRS_USUARIOS%NOTFOUND;
            NESTED_REG_ONLINE('002','',AC_USER.ACESSOS,AC_USER.USUARIO);
        END LOOP;
        COMMIT;
        ****/ 
        
        -- Envia registros de acessos do dia anterior 
        for ac_user in crs_log_eventos ('ACESSO') loop
            nested_reg_online('002','',ac_user.acessos,ac_user.usuario);
        end loop;
        commit;        

        -- Envia registros de alteração de usuário 
        for ac_user in crs_log_eventos ('USUARIO') loop
            nested_reg_online('012','',ac_user.acessos,ac_user.usuario);
        end loop;
        commit;

        BEGIN

            SELECT  CONTEUDO INTO WS_VARTEMP
            FROM    VAR_CONTEUDO
            WHERE   VARIAVEL = 'DATA_ATUAL';

            UPDATE VAR_CONTEUDO SET CONTEUDO=TO_CHAR(SYSDATE,'dd/mon/yyyy','NLS_DATE_LANGUAGE = AMERICAN')
                WHERE VARIAVEL IN ('DIA_TROCA','DATA_ATUAL');
            COMMIT;

            EXEC_DAY;

            INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-Novo Dia Final!' , USER , 'CALCULO' , 'OK', '0');
            COMMIT;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                UPDATE VAR_CONTEUDO SET CONTEUDO=TO_CHAR(SYSDATE,'dd/mon/yyyy','NLS_DATE_LANGUAGE = AMERICAN')
                WHERE VARIAVEL = 'DATA_ATUAL';
                UPDATE VAR_CONTEUDO SET CONTEUDO=WS_VARTEMP
                WHERE VARIAVEL = 'DIA_TROCA';
                COMMIT;
        END;

        NESTED_REG_ONLINE('003','VERIFY_DAY','OK');

    END IF;

    INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-FINAL NPROCESSO!' , USER , 'CALCULO' , 'OK', '0');
    COMMIT;

    BEGIN

        NESTED_STATUS_PROCESS('000006','JOB_QUARTER','END');
    EXCEPTION
        WHEN OTHERS THEN
            INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-PROCESSO SEM REGISTRO!' , USER , 'CALCULO' , 'OK', '0');
            COMMIT;
    END;

--end if;

EXCEPTION
    WHEN WS_NOACT THEN
         INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[OK]-NO ACT!' , USER , 'CALCULO' , 'OK', '0');
         COMMIT;
    WHEN WS_TIMEOUT THEN
         WS_ERRO := SQLERRM;
         INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-TIME OUT!' , USER , 'CALCULO' , 'OK', '0');
         COMMIT;
         NESTED_STATUS_PROCESS('000006','JOB_QUARTER','ERRO');
         NESTED_REG_ONLINE('001','JOB_QUARTER','ERRO');
         --FCL.INSERT_POST('','','','DWU','[JOB_QUARTER] - TIME OUT','1',PRM_SHOW => 'N', PRM_ORIGEM => 'SYS');
    WHEN OTHERS THEN
         WS_ERRO := SQLERRM;
         INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-ERRO NPROCESSO!' , USER , 'CALCULO' , 'OK', '0');
         COMMIT;
         NESTED_STATUS_PROCESS('000006','JOB_QUARTER','ERRO');
         NESTED_REG_ONLINE('001','JOB_QUARTER','ERRO');
         --FCL.INSERT_POST('','','','DWU','[JOB_QUARTER] - ERRO EXECUÇÃO','1',PRM_SHOW => 'N', PRM_ORIGEM => 'SYS');

END JOB_QUARTER;


procedure alert_online (p_id            in out number,
                        p_bloco		    varchar2 default null,
                        p_inicio        date     default null,
                        p_fim		    date     default null,
                        p_parametro	    varchar2 default null,
                        p_status 	    varchar2 default null,
                        p_obs	        varchar2 default null,
                        p_st_notify     varchar2 default 'REGISTRO',
                        p_mail_notify   varchar2 default 'N',
                        p_pipe_tabelas  varchar2 default null ) as  

-->> p_status     -- ATUALIZANDO
-->>              -- FINALIZADO 
-->>
-->> p_st_notify  -- "REGISTRO" Somente inserção na tabela VM_DETALHES
-->>              -- "ENVIO" Envia notificação parao CLOUD e VM_DETALHES
-->>
-->> p_mail_notify -- S - Envia email para suporte Upquery  
-->>               -- N - Não envia email    
 
cursor c_tabelas is
  select COLUMN_VALUE nm_tabela 
    from table ((FUN.VPIPE(p_pipe_tabelas))); 

ws_id          number;
ws_command     varchar2(4000);
ws_string      varchar2(4000);
ws_temp        varchar2(4000);
ws_notify      varchar2(40);
ws_sid         varchar2(20);
ws_serial      varchar2(20); 
ws_obs         varchar2(1000); 
ws_status      varchar2(100); 
ws_count       number; 

begin

    ws_notify  := p_st_notify;
    ws_status  := substr(p_status,1,100);
    ws_obs     := substr(p_obs,1,1000);

	begin

        if nvl(p_id,0) <> 0 then 
            ws_id := p_id ; 
        else     
            select nvl(max(id),0) + 1 into ws_id from vm_detalhes;
        end if;

        select count(*) into ws_count from vm_detalhes
         where vm_detalhes.id    = ws_id
           and vm_detalhes.bloco = p_bloco;
        -- Se já existe atualiza senão cria novo registro 
        if ws_count <> 0 then   
            update vm_detalhes set dt_hr_fim = p_fim, 
                                   parametro = nvl(p_parametro, parametro),
                                   status    = p_status, 
                                   obs       = p_obs
             where vm_detalhes.id    = ws_id
               and vm_detalhes.bloco = p_bloco ;
        else      
            select max(sid), max(serial#) into ws_sid , ws_serial 
              from v$session 
             where audsid = sys_Context('USERENV', 'SESSIONID') 
               and sid    = sys_Context('USERENV', 'SID');
	        insert into vm_detalhes ( id, bloco, dt_hr_inicio, dt_hr_fim, parametro, status, obs, cd_sid, cd_serial ) 
                             values (ws_id, p_bloco, p_inicio, p_fim, substr(p_parametro,1,100), p_status, substr(p_obs,1,4000), ws_sid, ws_serial);
        end if; 
        -- Atualiza o tempo de atualização nas visões 
        if p_fim is not null and p_status <> 'ERRO' then 
            select count(*) into ws_count 
              from all_tab_columns 
             where table_name = 'MICRO_VISAO'
               and column_name = 'DT_ULTIMA_ATUALIZACAO';
            if ws_count > 0 then 
                ws_command := 'update micro_visao set dt_ultima_atualizacao = :1 where nm_tabela = :2 ';  
                for a in c_tabelas loop
                    EXECUTE IMMEDIATE ws_command USING p_fim,  upper(a.nm_tabela); 
                    commit; 
                    --update micro_visao set dt_ultima_atualizacao = p_fim 
                    -- where nm_tabela = a.nm_tabela;
                end loop ;
            end if;    
        end if;    

        commit;
	exception
	   when others then
	        ws_notify  := 'ENVIO';
            ws_status  := 'ERRO_ALERT';
            ws_obs     := substr('Erro: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,1000);
	end;

    p_id := ws_id; 

    if  ws_notify = 'ENVIO' THEN
        begin
	        ws_command := 'http://'||fun.ret_var('DOMINIO_REG')||'/update/dwu.renew?prm_par=TIPO|010|CLIENTE|'||fun.ret_var('CLIENTE');
	        SELECT rawtohex(TO_CHAR(WS_ID)) INTO ws_temp FROM dual;
            ws_command := ws_command||'|ID|'||ws_temp;
            SELECT rawtohex(P_BLOCO) INTO ws_temp FROM dual;
            ws_command := ws_command||'|BLOCO|'||ws_temp;
            SELECT rawtohex(to_char(P_INICIO,'DD/MM/YYYY HH24:MI:SS')) INTO ws_temp FROM dual;
            ws_command := ws_command||'|INICIO|'||ws_temp;
            SELECT rawtohex(to_char(P_FIM,'DD/MM/YYYY HH24:MI:SS')) INTO ws_temp FROM dual;
            ws_command := ws_command||'|FIM|'||ws_temp;
            SELECT rawtohex(P_PARAMETRO) INTO ws_temp FROM dual;
            ws_command := ws_command||'|PARAMETRO|'||ws_temp;
            SELECT rawtohex(ws_status) INTO ws_temp FROM dual;
            ws_command := ws_command||'|STATUS|'||ws_temp;
            SELECT rawtohex(ws_obs) INTO ws_temp FROM dual;
            ws_command := ws_command||'|OBS|'||ws_temp;
            ws_command := ws_command||'|MAIL|'||p_mail_notify;
            commit;
          
            begin
                ws_string  := utl_http.request(ws_command);
            exception
                when others then
                    insert into PENDING_REGS values (sysdate,ws_command,'P');
                    commit;
            end;
        end;
    end if;
end alert_online; 



----------------------------------------------------------------------------------------------------
-- Registro online de todo o cadastro de usuarios - Usado somente para carga inicial, mas pode ser executado sempre que necessário 
----------------------------------------------------------------------------------------------------
procedure reg_online_usuario as 
    ws_command  varchar2(500);
    ws_string   varchar2(200);
begin
    for a in (select  usu_nome, '|NM_COMPLETO|'||rawtohex((USU_COMPLETO))||'|DS_EMAIL|'||rawtohex((USU_EMAIL))||'|NR_TELEFONE|'||rawtohex(USU_NUMBER)|| '|ID_SITUACAO|'||rawtohex(nvl((STATUS),'EXCLUIDO') )||
                                '|DT_ULTIMA_VALIDACAO|'||rawtohex(TO_CHAR((NULL),'DD/MM/YYYY HH24:MI:SS')) param 
                from usuarios ) loop 
        ws_command := 'http://'||sch.ret_var('DOMINIO_REG')||'/update/dwu.renew?prm_par=TIPO|012|CLIENTE|'||sch.ret_var('CLIENTE')||'|DATA|'||to_char(trunc(sysdate-1),'ddmmyyhh24mi')||'|USUARIO|'||a.usu_nome||a.param;
        begin
            ws_string  := utl_http.request(ws_command);
        exception
            when others then
                insert into PENDING_REGS values (sysdate,ws_command,'P');
                commit;
        end;         
    end loop;     
end reg_online_usuario;



----------------------------------------------------------------------------------------------------
-- Usado em Jobs para não utilizar/lockar a package FUN 
----------------------------------------------------------------------------------------------------
function ret_var  ( prm_variavel   varchar2 default null, 
                    prm_usuario    varchar2 default 'DWU' ) return varchar2 as

        cursor crs_variaveis is
            select 	conteudo
            from	VAR_CONTEUDO
            where	USUARIO = prm_usuario and
                VARIAVEL = replace(replace(prm_variavel, '#[', ''), ']', '');

        ws_variaveis	crs_variaveis%rowtype;

begin
        Open  crs_variaveis;
        Fetch crs_variaveis into ws_variaveis;
        close crs_variaveis;

        return (ws_variaveis.conteudo);
exception when others then
        return '';
end ret_var;
    



end SCH;
/
show error