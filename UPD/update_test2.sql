set scan off
create or replace procedure update_test2 ( prm_date date ) as
    ws_res     UTL_HTTP.HTML_PIECES;
    ws_req     varchar2(800);
    ws_output  clob;
    ws_linha   varchar2(400);
    ws_count    number := 0;
    ws_limit    number;
begin


    insert into bi_log_sistema values(sysdate, 'ATUALIZANDO PACKAGE DO SISTEMA', gbl.usuario, 'auto_update');
    commit;	

    ws_req := 'http://update.upquery.com/update/dwu.get_padroes?prm_tipo=PACKAGE&prm_chave=UPDATE';
    begin
        ws_res  := UTL_HTTP.REQUEST_PIECES(ws_req, 400);
        --loop do resultado
        for i in 1..ws_res.count LOOP
             ws_output := ws_output||ws_res(i);
        end loop;

        insert into err_txt values(ws_output);

        execute immediate 'create or replace '||ws_output;

        update bi_auto_update set ultimo_update = prm_date where tipo = 'UPLOAD';
        commit;

        insert into bi_log_sistema values(sysdate, 'PACKAGE COM SUCESSO', gbl.usuario, 'auto_update');
        commit;

    end;
exception when others then
    htp.p('PROBLEMAS');
    rollback;
    insert into bi_log_sistema values(sysdate, 'ERRO AO ATUALIZAR A PACKAGE', gbl.usuario, 'auto_update');
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.usuario, 'auto_update_error');
    commit;
end update_test2;
