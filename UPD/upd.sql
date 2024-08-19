set scan off
-- >>>>>>>------------------------------------------------------------------------
-- >>>>>>> Aplicação:	AUTO UPDATE
-- >>>>>>> Por:		Upquery
-- >>>>>>> Data:	06/08/2020
-- >>>>>>> Pacote:	UPD
-- >>>>>>>------------------------------------------------------------------------
-- >>>>>>>------------------------------------------------------------------------
create or replace package  UPD  is

    procedure padroes;

    procedure constantes;

    procedure packages ( prm_chave varchar2 );

    procedure documentos ( prm_chave varchar2 );

    function  validar ( prm_chave varchar2 ) return varchar2;

    procedure iniciaUpdate ( prm_chave varchar2, prm_msg varchar2 );

    procedure query;

    procedure finalizaUpdate ( prm_chave varchar2, prm_date date, prm_msg varchar2 );

    procedure errorUpdate ( prm_chave varchar2, prm_msg varchar2 );

    function c2b ( p_clob IN CLOB ) return blob;

    function ret_var  ( prm_variavel   varchar2 default null, 
                        prm_usuario    varchar2 default 'DWU' ) return varchar2;
    
    FUNCTION VPIPE ( PRM_ENTRADA VARCHAR2,
                     PRM_DIVISAO VARCHAR2 DEFAULT '|' ) RETURN CHARRET PIPELINED;

end UPD;
/
create or replace package body UPD  is

procedure padroes  as
    ws_res     UTL_HTTP.HTML_PIECES;
    ws_req     varchar2(800);
    ws_output  varchar2(30000) := '';
    ws_linha   varchar2(400);
    ws_count   number := 0;
    ws_limit   number;
begin

    if instr(upd.validar(upd.ret_var('CLIENTE')), 'S') > 0 then

        iniciaUpdate('PADROES', 'ATUALIZANDO PADR&Otilde;ES DO SISTEMA');

        ws_req := 'http://'||nvl(UPD.RET_VAR('DOMINIO_REG'),'update.upquery.com')||'/update/dwu.get_padroes?prm_tipo=PADRAO_COUNT';

        ws_limit := to_number(replace(replace(trim(Utl_Http.Request(ws_req)), chr(10), ''), chr(13), ''));

        /* backup dos padroes caso erro */
        delete from BI_OBJECT_PADRAO_BKP;
        commit;

        insert into BI_OBJECT_PADRAO_BKP (select * from BI_OBJECT_PADRAO);
        commit;

        delete from BI_OBJECT_PADRAO;
        commit;

        ws_req := 'http://'||nvl(UPD.RET_VAR('DOMINIO_REG'),'update.upquery.com')||'/update/dwu.get_padroes?prm_tipo=PADROES';

        begin
            ws_res  := UTL_HTTP.REQUEST_PIECES(ws_req, 200);
            --loop do resultado
            for i in 1..ws_res.count LOOP
                ws_output := ws_output||ws_res(i);
                while instr(ws_output, ';') <> 0 loop
                    ws_linha := substr(ws_output, 0, instr(ws_output, ';'));
                    execute immediate replace(ws_linha, ';', '');
                    ws_count := ws_count+1;
                    if ws_count > ws_limit then
                        exit;
                    end if;
                    ws_output := replace(ws_output, ws_linha, '');
                end loop;
            end loop;
        end;

        finalizaUpdate('PADROES', sysdate, 'PADR&Otilde;ES ATUALIZADOS COM SUCESSO');

    end if;

exception when others then
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, user, 'ERRO');
    commit;
    htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    errorUpdate('PADROES', 'ERRO AO ATUALIZAR OS PADR&Otilde;ES');
    select count(*) into ws_count from BI_OBJECT_PADRAO;
    if ws_count = 0 then
        insert into BI_OBJECT_PADRAO (select * from BI_OBJECT_PADRAO_BKP);
        commit;
    end if;
end padroes;

procedure constantes  as
    ws_res     UTL_HTTP.HTML_PIECES;
    ws_req     varchar2(800);
    ws_output  varchar2(30000) := '';
    ws_linha   varchar2(30000);
    ws_count   number := 0;
    ws_limit   number;
begin

    if instr(upd.validar(upd.ret_var('CLIENTE')), 'S') > 0 then
    
        iniciaUpdate('CONSTANTES', 'ATUALIZANDO CONSTANTES DO SISTEMA');
        
        ws_req := 'http://'||nvl(UPD.RET_VAR('DOMINIO_REG'),'update.upquery.com')||'/update/dwu.get_padroes?prm_tipo=CONSTANTE_COUNT';

        ws_limit := to_number(replace(replace(trim(Utl_Http.Request(ws_req)), chr(10), ''), chr(13), ''));
        
        /* backup dos padroes caso erro */
        delete from BI_CONSTANTES_BKP;
        commit;

        insert into BI_CONSTANTES_BKP (select * from BI_CONSTANTES);
        commit;

        delete from BI_CONSTANTES;
        ws_req := 'http://'||nvl(UPD.RET_VAR('DOMINIO_REG'),'update.upquery.com')||'/update/dwu.get_padroes?prm_tipo=CONSTANTES';

        begin
            ws_res  := UTL_HTTP.REQUEST_PIECES(ws_req, 200);
            --loop do resultado
            for i in 1..ws_res.count LOOP
                ws_output := ws_output||ws_res(i);
                while instr(ws_output, ';') <> 0 loop
                    ws_linha := substr(ws_output, 0, instr(ws_output, ';'));
                    execute immediate replace(ws_linha, ';', '');
                    ws_count := ws_count+1;
                    if ws_count > ws_limit then
                        exit;
                    end if;
                    ws_output := replace(ws_output, ws_linha, '');
                end loop;
            end loop;
        end;

        finalizaUpdate('CONSTANTES', sysdate, 'CONSTANTES ATUALIZADAS COM SUCESSO');
        commit;

    end if;

exception when others then
    
    rollback;
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, '', 'ERRO');
    insert into bi_log_sistema values(sysdate, substr('Erro AutoUpdate Constantes:'||ws_linha,1,4000) , '', 'ERRO');
    
    commit;
    htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    errorUpdate('CONSTANTES', 'ERRO AO ATUALIZAR AS CONSTANTES');
    
    select count(*) into ws_count from BI_CONSTANTES;
    if ws_count = 0 then
        insert into BI_CONSTANTES (select * from BI_CONSTANTES_BKP);
        commit;
    end if;

end constantes;

procedure packages ( prm_chave varchar2 ) as
    ws_res_head     UTL_HTTP.HTML_PIECES;
    ws_res_body     UTL_HTTP.HTML_PIECES;
    ws_req       varchar2(800);
    ws_output    clob;
    ws_linha     varchar2(400);
    ws_count     number := 0;
    ws_limit     number;
begin

    if instr(upd.validar(upd.ret_var('CLIENTE')), 'S') > 0 then

        ws_output := '';

        iniciaUpdate(prm_chave, 'ATUALIZANDO PACKAGE '||prm_chave||' DO SISTEMA');

        begin

            --HEAD
            ws_req := 'http://'||nvl(UPD.RET_VAR('DOMINIO_REG'),'update.upquery.com')||'/update/dwu.get_padroes?prm_tipo=PACKAGE_HEAD&prm_chave='||prm_chave;

            ws_res_head  := UTL_HTTP.REQUEST_PIECES(ws_req, 200);
            --loop do resultado
            for h in 1..ws_res_head.count LOOP
                ws_output := ws_output||ws_res_head(h);
            end loop;

            ws_output := 'create or replace '||ws_output;

            execute immediate ws_output;

            ws_output := '';

            --BODY
            ws_req := 'http://'||nvl(UPD.RET_VAR('DOMINIO_REG'),'update.upquery.com')||'/update/dwu.get_padroes?prm_tipo=PACKAGE&prm_chave='||prm_chave;

            ws_res_body  := UTL_HTTP.REQUEST_PIECES(ws_req, 200);
            --loop do resultado
            for b in 1..ws_res_body.count LOOP
                ws_output := ws_output||ws_res_body(b);
            end loop;

            ws_output := 'create or replace '||ws_output;

            execute immediate ws_output;

            --COMPILE
            --verificar necessidade de validar
            execute immediate 'ALTER PACKAGE '||prm_chave||' COMPILE';
            execute immediate 'ALTER PACKAGE '||prm_chave||' COMPILE PACKAGE';

        end;

        finalizaUpdate(prm_chave, sysdate, 'PACKAGE '||prm_chave||' ATUALIZADA COM SUCESSO');

    end if;

exception when others then

    if instr(DBMS_UTILITY.FORMAT_ERROR_STACK, 'success with compilation') > 0 then
        htp.p('PACKAGE '||prm_chave||' ATUALIZADA COM ERROS DE COMPILA&Ccedil;&Atilde;O');
        insert into bi_log_sistema values(sysdate, 'ERRO DE COMPILA&Ccedil;&Atilde;O AO TENTAR ATUALIZAR', '', 'auto_update');
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, user, 'auto_update_error');
        update bi_auto_update set status = 'C' 
        where tipo = prm_chave;
        commit;
    else
        htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        errorUpdate(prm_chave, 'ERRO AO ATUALIZAR A PACKAGE '||prm_chave);
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, user, 'ERRO');
        commit;
    end if;

end packages;

procedure documentos ( prm_chave varchar2 ) as
    ws_res         UTL_HTTP.HTML_PIECES;
    ws_req         varchar2(800);
    ws_output      clob;
    ws_nome        varchar2(100);
    ws_count       number := 0;
    ws_limit       number;
    ws_invalidlob  exception;
begin

    if instr(upd.validar(upd.ret_var('CLIENTE')), 'S') > 0 then

        ws_output := '';
        iniciaUpdate(prm_chave, 'ATUALIZANDO ARQUIVO '||prm_chave||'');

        begin

            case prm_chave 
                when 'JS' then
                    ws_nome := 'default-min.js';
                when 'CSS' then
                    ws_nome := 'default-min.css';
            end case;

            --HEAD
            ws_req := 'http://'||nvl(UPD.RET_VAR('DOMINIO_REG'),'update.upquery.com')||'/update/dwu.get_padroes?prm_tipo=ARQUIVO&prm_chave='||ws_nome;
            ws_res  := UTL_HTTP.REQUEST_PIECES(ws_req, 200);

            --loop do resultado
            for i in 1..ws_res.count LOOP
                ws_output := ws_output||ws_res(i);
            end loop;
 
            update tab_documentos set BLOB_CONTENT = upd.C2B(ws_output) where name = ws_nome;
            commit;

        end;

        select count(*) into ws_count from tab_documentos where name = ws_nome and blob_content is not null;
        if ws_count = 0 then
            raise ws_invalidlob;
        end if;

        finalizaUpdate(prm_chave, sysdate, 'ARQUIVO '||prm_chave||' ATUALIZADO COM SUCESSO');

    end if;

exception 

    when ws_invalidlob then
        htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        errorUpdate(prm_chave, 'LOB INVALIDO DO ARQUIVO '||prm_chave);
        insert into bi_log_sistema values(sysdate, 'Lob inválido de arquivo', '', 'ERRO');
        commit;
    
    when others then
        htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        errorUpdate(prm_chave, 'ERRO AO ATUALIZAR O ARQUIVO '||prm_chave);
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, '', 'ERRO');
        commit;

end documentos;

procedure query as

    ws_data        date;
    ws_req_list    varchar2(400);
    ws_res         varchar2(400);
    ws_output      varchar2(4000);
    ws_output_list varchar2(400);
begin

    /*if instr(upd.validar(upd.ret_var('CLIENTE')), 'S') > 0 then

        ws_output := '';
        iniciaUpdate('QUERY', 'EXECUTANDO QUERY');

            begin
                select ultimo_update into ws_data from bi_auto_update where tipo = 'QUERY';
            exception when others then
                ws_data := add_months(sysdate, -1);
            end;

            ws_req_list := 'http://'||nvl(UPD.RET_VAR('DOMINIO_REG'),'update.upquery.com')||'/update/dwu.get_padroes?prm_tipo=QUERY&prm_chave=';
            ws_output_list  := trim(UTL_HTTP.REQUEST(ws_req_list));

            for i in( select cd_coluna, cd_conteudo from table(fun.vpipe_par(ws_output_list)) where to_date(cd_conteudo, 'DD-MM-YYYY') > ws_data) loop

                ws_res     := 'http://'||nvl(UPD.RET_VAR('DOMINIO_REG'),'update.upquery.com')||'/update/dwu.get_padroes?prm_tipo=QUERY&prm_chave='||trim(i.cd_coluna);
                ws_output  := trim(UTL_HTTP.REQUEST(ws_res));
                execute immediate ws_output;

            end loop;

        finalizaUpdate('QUERY', sysdate, 'QUERY EXECUTADA COM SUCESSO');

    end if;
exception when others then

    htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    --errorUpdate(prm_chave, 'Erro ao executar a query '||prm_chave);
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, '', 'ERRO');
    commit;*/
    null;

end query;

function validar ( prm_chave varchar2 ) return varchar2 as
    ws_res     varchar2(400);
    ws_req     varchar2(800);
begin

    begin

        --Precisa estar registrado na BI_PERMISSAO_UPDATE
        ws_req := 'http://'||nvl(UPD.RET_VAR('DOMINIO_REG'),'update.upquery.com')||'/update/dwu.get_padroes?prm_tipo=VALIDAR&prm_chave='||trim(prm_chave);
        ws_res  := trim(UTL_HTTP.REQUEST(ws_req));

        return ws_res;

    end;

exception when others then
   return sqlerrm;
end validar;

procedure iniciaUpdate ( prm_chave varchar2,
                         prm_msg   varchar2 ) as

begin

    insert into bi_log_sistema values(sysdate, prm_msg, gbl.getUsuario, 'EVENTO');
    commit;	

    update bi_auto_update set status = 'U' 
    where tipo = prm_chave;
    commit;

end iniciaUpdate;

procedure finalizaUpdate ( prm_chave varchar2,
                           prm_date  date,
                           prm_msg   varchar2 ) as

begin

    merge into bi_auto_update b
        using (select prm_chave as p_chave, prm_date as p_date from dual) t1 on (b.tipo = t1.p_chave)
        when matched then
            update set ultimo_update = t1.p_date where tipo = t1.p_chave
        when not matched then
            insert values (t1.p_chave, t1.p_date, '', ''); 

    commit;

    insert into bi_log_sistema values(sysdate, prm_msg, gbl.getUsuario, 'EVENTO');
    commit;

    htp.p(to_char(prm_date, 'DD/MM/YYYY'));

    update bi_auto_update set status = 'K' 
    where tipo = prm_chave;
    commit;

end finalizaUpdate;

procedure errorUpdate ( prm_chave varchar2,
                        prm_msg   varchar2 ) as

begin

    htp.p(prm_msg);
    rollback;

    insert into bi_log_sistema values(sysdate, prm_msg, '', 'EVENTO');
    commit;

    update bi_auto_update set status = 'F' 
    where tipo = prm_chave;
    commit;

end errorUpdate;

function c2b ( p_clob IN CLOB ) return blob is

  temp_blob   BLOB;
  dest_offset NUMBER  := 1;
  src_offset  NUMBER  := 1;
  amount      INTEGER := dbms_lob.lobmaxsize;
  blob_csid   NUMBER  := dbms_lob.default_csid;
  lang_ctx    INTEGER := dbms_lob.default_lang_ctx;
  warning     INTEGER;

BEGIN
    DBMS_LOB.CREATETEMPORARY( lob_loc => temp_blob, cache => TRUE );

    DBMS_LOB.CONVERTTOBLOB(temp_blob, p_clob,amount,dest_offset,src_offset,blob_csid,lang_ctx,warning);
    Return Temp_Blob;
END c2b;

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

FUNCTION VPIPE ( PRM_ENTRADA VARCHAR2,
                 PRM_DIVISAO VARCHAR2 DEFAULT '|' ) RETURN CHARRET PIPELINED AS

   WS_BINDN      NUMBER;
   WS_TEXTO      VARCHAR2(12000);
   WS_NM_VAR      VARCHAR2(12000);
   WS_FLAG         CHAR(1);

BEGIN

   WS_FLAG  := 'N';
   WS_BINDN := 0;
   WS_TEXTO := PRM_ENTRADA;

   LOOP
       IF  WS_FLAG = 'Y' THEN
           EXIT;
       END IF;

       IF  NVL(INSTR(WS_TEXTO,PRM_DIVISAO),0) = 0 THEN
      WS_FLAG  := 'Y';
      WS_NM_VAR := WS_TEXTO;
       ELSE
      WS_NM_VAR := SUBSTR(WS_TEXTO, 1 ,INSTR(WS_TEXTO,PRM_DIVISAO)-1);
      WS_TEXTO  := SUBSTR(WS_TEXTO, LENGTH(WS_NM_VAR||PRM_DIVISAO)+1, LENGTH(WS_TEXTO));
       END IF;

       WS_BINDN := WS_BINDN + 1;
       PIPE ROW (WS_NM_VAR);

   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      PIPE ROW(SQLERRM||'=RET_LIST');

END VPIPE;
   

end UPD;
/
show error