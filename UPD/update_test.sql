create or replace procedure update_test ( prm_date date ) as
    ws_res     UTL_HTTP.HTML_PIECES;
    ws_req     varchar2(800);
    ws_output  varchar2(30000) := '';
    ws_linha   varchar2(400);
    ws_count    number := 0;
    ws_limit    number;
begin
    
    insert into bi_log_sistema values(sysdate, 'ATUALIZANDO PADRÕES DO SISTEMA', gbl.usuario, 'auto_update');
    commit;	
    
    ws_req := 'http://update.upquery.com/update/dwu.get_padroes?prm_tipo=PADRAO_COUNT';

    ws_limit := to_number(replace(replace(trim(Utl_Http.Request(ws_req)), chr(10), ''), chr(13), ''));
    

    ws_req := 'http://update.upquery.com/update/dwu.get_padroes?prm_tipo=PADROES';
    begin
        ws_res  := UTL_HTTP.REQUEST_PIECES(ws_req, 400);
        --loop do resultado
        for i in 1..ws_res.count LOOP
         ws_output := ws_output||ws_res(i);
          --htp.p('----'||i||'----');
          --htp.p('in '||ws_output);
          while instr(ws_output, ';') <> 0 loop
              --htp.p('tick');
              ws_linha := substr(ws_output, 0, instr(ws_output, ';'));
              --truncate table bi_object_padrao;
              execute immediate replace(ws_linha, ';', '');
              ws_count := ws_count+1;
              if ws_count > ws_limit then
                  exit;
              end if;
              --htp.prn(ws_linha||'-------');
              --htp.p('out 1'||ws_output);
              ws_output := replace(ws_output, ws_linha, '');
              --htp.p('out '||ws_output);
          end loop;
          --htp.prn(ws_string(i));
        end loop;
    end;

    update bi_auto_update set ultimo_update = prm_date where tipo = 'PADROES';
    commit;

    insert into bi_log_sistema values(sysdate, 'PACKAGE COM SUCESSO', gbl.usuario, 'auto_update');
    commit;

exception when others then
    htp.p('PROBLEMAS');
    rollback;
    insert into bi_log_sistema values(sysdate, 'ERRO AO ATUALIZAR OS PADROES', gbl.usuario, 'auto_update');
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.usuario, 'auto_update_error');
    commit;
end update_test;