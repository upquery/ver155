create or replace procedure get_padroes ( prm_tipo     varchar2 default null,
                                          prm_chave    varchar2 default null,
                                          prm_sequence number   default null ) as

    cursor crs_padroes is select TP_OBJETO, CD_PROP, CD_TIPO, LABEL, VL_DEFAULT, SUFIXO, SCRIPT, VALIDACAO, ST_PERSONALIZADO, ORDEM, GRUPO, HINT 
    from bi_object_padrao
    where upper(trim(TP_OBJETO)) = upper(trim(nvl(prm_chave, TP_OBJETO)));
    ws_padrao crs_padroes%rowtype;

    cursor crs_estados is select cd_estado, nm_estado, json, sequencia from 
    bi_estados_brasil;
    ws_estado crs_estados%rowtype;
    
    cursor crs_cidades is 
    select cd_cidade, replace(nm_cidade, chr(39), '') as nm_cidade, cd_estado, 
    nm_estado, sequencia
    from bi_cidades_brasil;
    ws_cidade crs_cidades%rowtype;
    
    cursor crs_arquivos is
    select NAME, MIME_TYPE, DOC_SIZE, DAD_CHARSET, 
    LAST_UPDATED, CONTENT_TYPE, BLOB_CONTENT
    from tab_documentos
    where usuario = 'SYS' and BLOB_CONTENT is not null;
    ws_arquivo crs_arquivos%rowtype;

    ws_lista varchar2(800);
    ws_json  clob;
    ws_blob  blob;
    ws_res   clob;

    ws_dest_offset    number := 1;
    ws_src_offset     number := 1;
    ws_conversao      varchar2(40) := 'WE8MSWIN1252';
    ws_lang_context   number := 0;
    ws_warning        number;
    ws_count          number := 0;
    ws_ultimo         date;

    --lob de arquivos
    Lob_Bytes_Remaining Number(10);
    Buffer              Raw(1000);
    Amount              Binary_Integer := 1000;
    Position            Integer := 1;
    Chunksize           Integer;
    ws_variavel         varchar2(2000);

begin

    case prm_tipo
    
    when 'TABLES' then
    
        for i in(select table_name from all_tables where owner = 'DWU' and table_name like ('%BI%')) loop
        
            select dbms_metadata.get_ddl('TABLE', i.table_name) DDL into ws_lista from dual;
            htp.p(ws_lista);

        end loop;
 
    
    when 'ARQUIVOS' then
    
        open crs_arquivos;
            loop
                fetch crs_arquivos into ws_arquivo;
                exit when crs_arquivos%notfound;
                   htp.p('insert into tab_documentos values('''||ws_arquivo.NAME||''', '''||ws_arquivo.MIME_TYPE||''', '''||ws_arquivo.DOC_SIZE||''', '''||ws_arquivo.DAD_CHARSET||''', '''||ws_arquivo.LAST_UPDATED||''', '''||ws_arquivo.CONTENT_TYPE||''', '''', ''SYS'');');
            end loop;
        close crs_arquivos;
    when 'ARQUIVO' then

        select VALUE into ws_conversao
        from NLS_DATABASE_PARAMETERS
        where PARAMETER='NLS_CHARACTERSET';
    
        select blob_content into ws_blob from tab_documentos where name = prm_chave;
        /*dbms_lob.createtemporary(ws_json, true, dbms_lob.call);
        dbms_lob.converttoclob(ws_json, ws_blob, dbms_lob.lobmaxsize, ws_dest_offset, ws_src_offset, nls_charset_id(ws_conversao), ws_lang_context, ws_warning);
        htp.p(ws_json);*/

        lob_bytes_remaining := dbms_lob.getlength(ws_blob);
        chunksize := dbms_lob.getchunksize(ws_blob);
        if (chunksize < 1000) then
           amount := (1000 / chunksize) * chunksize;
        End If;
        
        begin
            dbms_lob.open(ws_blob, dbms_lob.LOB_READONLY);

            while (lob_bytes_remaining > 0) Loop
            
                if (lob_bytes_remaining < amount) Then
                    amount := lob_bytes_remaining;
                end if;

                dbms_lob.Read(ws_blob, amount, Position, Buffer);

                ws_variavel := utl_raw.cast_to_varchar2(buffer);
                
                ws_count := 1;
                loop
                    if ws_count > length(ws_variavel) then
                        exit;
                    end if;

                    htp.prn(substr(ws_variavel, ws_count, 1));

                    ws_count := ws_count + 1;
                end loop;

                position := position + amount;

                lob_bytes_remaining := lob_bytes_remaining - amount;

            End Loop;
            dbms_lob.Close(ws_blob);
        exception when others then
            htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        end;
    
    when 'CIDADES' then

         open crs_cidades;
            loop
                fetch crs_cidades into ws_cidade;
                exit when crs_cidades%notfound;
                    htp.p('insert into bi_cidades_brasil values ('''||ws_cidade.cd_cidade||''', '''||ws_cidade.nm_cidade||''', '''||ws_cidade.cd_estado||''', '''||ws_cidade.nm_estado||''', '''', '''||ws_cidade.sequencia||''');');
            end loop;
        close crs_cidades;
        
    when 'CIDADE' then
    
        select json into ws_json from bi_cidades_brasil where cd_cidade = prm_chave and sequencia = prm_sequence;
        htp.p(ws_json);
        
    when 'ESTADOS' then

         open crs_estados;
            loop
                fetch crs_estados into ws_estado;
                exit when crs_estados%notfound;
                    htp.p('insert into bi_estados_brasil values ('''||ws_estado.cd_estado||''', '''||ws_estado.nm_estado||''', '''', '''||ws_estado.sequencia||''');');
            end loop;
        close crs_estados;

    when 'ESTADO' then
    
        select json into ws_json from bi_estados_brasil where cd_estado = prm_chave and sequencia = prm_sequence;
        htp.p(ws_json);
        
     when 'PACKAGE_HEAD' then
        
        for i in(select text  from all_source where name = prm_chave 
        and type = 'PACKAGE'
        order by line) loop
             --ws_res := ws_res||;
            htp.prn(i.text);
        end loop;
        
        --htp.prn(ws_res);
        
    when 'PACKAGE' then
        
        for i in(select text from all_source where name = prm_chave 
        and type = 'PACKAGE BODY'
        order by line) loop
            --ws_res := ws_res||;
            htp.prn(i.text);
        end loop;
        
        --htp.prn(ws_res);
        
    when 'PADROES' then

        open crs_padroes;
            loop
                fetch crs_padroes into ws_padrao;
                exit when crs_padroes%notfound;
                    htp.p('Insert into BI_OBJECT_PADRAO values ('''||ws_padrao.TP_OBJETO||''', '''||ws_padrao.CD_PROP||''', '''||ws_padrao.CD_TIPO||''', '''||ws_padrao.LABEL||''', '''||ws_padrao.VL_DEFAULT||''', '''||ws_padrao.SUFIXO||''', '''||ws_padrao.SCRIPT||''', '''||ws_padrao.VALIDACAO||''', '''||ws_padrao.ST_PERSONALIZADO||''', '''||ws_padrao.ORDEM||''', '''||ws_padrao.GRUPO||''', '''||ws_padrao.HINT||''');');
            end loop;
        close crs_padroes;

        
   
    when 'PADRAO_COUNT' THEN
    
        select count(*) into ws_count
        from bi_object_padrao
        where upper(trim(TP_OBJETO)) = upper(trim(nvl(prm_chave, TP_OBJETO)));
        htp.p(ws_count);
    
    when 'CHECK_UPDATES' THEN
    
        select listagg(tipo||'|'||to_char(ultimo_update, 'DD-MM-YYYY'), '|') within group (order by tipo) into ws_lista
        from bi_auto_update;
        htp.p(ws_lista);
        
    when 'CHECK_UPDATE' THEN
    
        select ultimo_update into ws_ultimo
        from bi_auto_update
        where upper(trim(tipo)) = upper(trim(prm_chave));
        htp.p(ws_ultimo);
    
    when 'VALIDAR' then
        
        select status into ws_lista from bi_permissao_update where cd_cliente = prm_chave;
        htp.p(ws_lista);
    
    else 
        select listagg(tp_objeto, ', ') within group (order by tp_objeto) into ws_lista from(select distinct tp_objeto from bi_object_padrao);
        htp.p(upper(trim(ws_lista))||',');
   
    end case;
    
    /*
    
    com base na bi_auto_update
    --create table bi_auto_update ( tipo varchar2(80), ultimo_update date );
    
    implementação
    
    
    
    declare
  ws_url varchar2(200);
  ws_req UTL_HTTP.req;
  ws_pcs utl_http.html_pieces;
  ws_res UTL_HTTP.resp;
  ws_str varchar2(32000);
begin
     
     ws_url := 'http://'||fun.ret_var('DOMINIO_REG')||'/update/dwu.get_padroes?prm_tipo=PADROES';
     ws_req :=  utl_http.begin_request(ws_url);

     //for I IN 1..ws_pcs.count loop
     //    ws_res := ws_res||ws_pcs(I);
     //end loop;
     
     ws_res := utl_http.get_response(ws_req);
     
     BEGIN
        LOOP
          utl_http.read_text(ws_res, ws_str, 32000);
          htp.p(ws_str);
        END LOOP;
      EXCEPTION
        WHEN utl_http.end_of_body THEN
          utl_http.end_response(ws_res);
      END;
  
    -- htp.p(ws_res);
     --delete from tab_documentos where name = 'padroes.txt';
     --insert into tab_documentos values ('padroes.txt','text/plain', Dbms_Lob.Getlength(ws_res),'ascii',sysdate,'BLOB',c2b(ws_res),'DWU');

end;*/
    
    
    
exception when others then
    htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
end get_padroes;