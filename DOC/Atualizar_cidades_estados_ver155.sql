
--------------------------------------------------------------------------------------
-- Atualizar CIDADES / ESTADOS na versão 1.5.5 - Executar na base do cliente 
--------------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE BI_AUTO_UPDATE_TEMP (
  TP_OBJETO  		  VARCHAR2(50), 
	NM_OBJETO		  VARCHAR2(100), 
	SQ_OBJETO		  NUMBER, 
	ST_ATUALIZACAO	  VARCHAR2(20), 
	CONTEUDO_TAMANHO  NUMBER
   ) ON COMMIT PRESERVE ROWS ; 
--   
alter table bi_cidades_brasil add sequencia number; 
--
SET DEFINE OFF; 
DECLARE 
    --
    prm_sistema       varchar2(10) := 'BI' ; 
    prm_versao        varchar2(10) := '1.5.6'; 
    prm_usuario       varchar2(10) := 'DWU';
    prm_tipo          VARCHAR2(10) := 'CIDADES'; 
    ws_res           UTL_HTTP.HTML_PIECES;
    ws_resN          varchar2(4000);
    ws_req           varchar2(800);
    ws_url           varchar2(100);    
    ws_nome          varchar2(20);
    ws_sysdate       date; 
    -- 
    ws_output        clob;
    ws_linha         varchar2(400);
    ws_count         number := 0;
    ws_limit         number;
    ws_qt_insert     number; 
    ws_qt_obj        number; 
    ws_qt_res        number; 
    ws_msg           varchar2(500);
    ws_msg_log       varchar2(500);
    ws_tam_aux       number; 
    ws_id_atu        number;
    ws_erro_atualizando exception ;
begin
    ws_url       := 'update.upquery.com/update';
    ws_nome      := 'TODOS'; 
    ws_msg       := null; 
    ws_msg_log   := null; 
    delete bi_auto_update_temp; 
    -- Busca a lista de CIDADES ou ESTADOS e insere(merge) nas tabelas (sem o JSON) 
    -----------------------------------------------------------------------------------
    ws_req       := 'http://'||ws_url||'/dwu.beup.get_update_sistema?prm_chave=&prm_sistema='||prm_sistema||'&prm_versao='||prm_versao||'&prm_tipo='||prm_tipo||'&prm_nm_conteudo='||ws_nome;
    ws_res       := UTL_HTTP.REQUEST_PIECES(ws_req, 32767);
    ws_output    := ' ';         
    for a in 1..ws_res.count LOOP
       ws_output := ws_output||ws_res(a);
    end loop;

    if trim(ws_output) LIKE 'ERRO|%' then 
       ws_msg_log := replace(ws_output,'ERRO|','');
       raise ws_erro_atualizando;
    end if; 
    ws_qt_insert := 0; 
    while instr(ws_output, ';') <> 0 loop
        ws_linha   := substr(ws_output, 0, instr(ws_output, ';'));
        begin
            execute immediate replace(ws_linha, ';', '');
            if upper(ws_linha) not like '%BI_AUTO_UPDATE_TEMP%' then 
                ws_qt_insert := ws_qt_insert + 1;
            end if;                       
            commit;                
        exception when others then 
            ws_msg_log := DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            raise ws_erro_atualizando; 
        end;        
        ws_count := ws_count+1;
        exit when ( ws_count > ws_limit ); 
        ws_output := replace(ws_output, ws_linha, '');
    end loop;
    -- Busca e atualiza o JSON com as coordenadas dos estados ou cidades 
    -----------------------------------------------------------------------------------
    ws_qt_obj := 0;
    ws_qt_res := 0;
    for a in (select tp_objeto, nm_objeto, sq_objeto, conteudo_tamanho from bi_auto_update_temp order by 1,2,3) loop 
        ws_qt_res := ws_qt_res + 1;
        if a.tp_objeto = 'ESTADOS' then 
            select max(length(json)) into ws_tam_aux from bi_estados_brasil 
             where cd_estado = a.nm_objeto 
               and sequencia = a.sq_objeto; 
        elsif a.tp_objeto = 'CIDADES' then 
            select max(length(json)) into ws_tam_aux from bi_cidades_brasil 
             where cd_cidade = a.nm_objeto 
               and sequencia = a.sq_objeto;        
        end if;        
        -- Busca Json para atualização - Somente se o tamanho do JSON não mudou 
        if  nvl(ws_tam_aux,0) <> a.conteudo_tamanho then 
            ws_req       := 'http://'||ws_url||'/dwu.beup.get_update_sistema?prm_chave=&prm_sistema='||prm_sistema||'&prm_versao='||prm_versao||'&prm_tipo='||a.tp_objeto||'&prm_nm_conteudo='||a.nm_objeto||'|'||a.sq_objeto;
            ws_res       := UTL_HTTP.REQUEST_PIECES(ws_req, 32767);
            ws_output    := null;        
            for a in 1..ws_res.count LOOP
                ws_output := ws_output||ws_res(a);
            end loop;
            if trim(ws_output) LIKE 'ERRO|%' then 
                ws_msg_log := replace(ws_output,'ERRO|','');
                raise ws_erro_atualizando;
            end if; 
            if NVL(ws_output,'N/A') <> 'N/A' then 
                begin
                    if prm_tipo = 'ESTADOS' then 
                        update bi_estados_brasil set json = ws_output
                        where cd_estado = a.nm_objeto
                        and sequencia = a.sq_objeto ;
                    elsif prm_tipo = 'CIDADES' then   
                        update bi_cidades_brasil set json = ws_output
                        where cd_cidade = a.nm_objeto
                        and sequencia = a.sq_objeto ;
                    end if;       
                    ws_qt_obj := ws_qt_obj + 1;
                    commit; 
                exception when others then 
                    ws_msg_log := DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
                    raise ws_erro_atualizando; 
                end;        
            end if;    
            commit;                
        end if;     
        --
    end loop;   
    -- 
    commit; 
 exception 
    when ws_erro_atualizando then 
        rollback; 
        insert into bi_log_sistema (dt_log, ds_log,nm_usuario, nm_procedure) values(sysdate, 'autoUpdate_CIDADES_ESTADOS:'||ws_msg_log, prm_usuario, 'EVENTO');         
        commit; 
        ws_msg := 'Erro atualizando <'||UPPER(prm_tipo)||'>, entre em contato com o administrador do sistema'; 
    when others then
        rollback;
        ws_msg_log := 'ERRO:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
        insert into bi_log_sistema (dt_log, ds_log,nm_usuario, nm_procedure) values(sysdate, 'autoUpdate_CIDADES_ESTADOS(outros):'||ws_msg_log, prm_usuario, 'EVENTO');         
        commit; 
        ws_msg := 'Erro atualizando <'||UPPER(prm_tipo)||'>, JSON atualizados '||ws_qt_obj||', entre em contato com o administrador do sistema';
end;
