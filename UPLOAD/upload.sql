set scan off

-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Aplicação: Upload
-- >>>>>>> Por:		Upquery Tec
-- >>>>>>> Data:	18/04/12
-- >>>>>>> Pacote:	Upload
-- >>>>>>>-------------------------------------------------------------

create or replace package upload is
	
	procedure main ( prm_alternativo varchar2 default null );
	
	PROCEDURE upload (arquivo  IN  VARCHAR2, prm_usuario varchar2 default null);

  Procedure Download;

	Procedure Download ( arquivo  In  Varchar2 );
	
end upload;
/

create or replace package body upload is

	procedure main ( prm_alternativo varchar2 default null ) as
	
		ws_count   number := 0;
        ws_coluna  varchar2(400);
        ws_tabela  varchar2(400);
	
		begin
		htp.htmlopen;
		  htp.headopen;
		  htp.title('Upload Arquivo');
		  htp.headclose;
		  htp.p('<body style="margin: 0;">');

		  htp.p('<form enctype="multipart/form-data" action="dwu.upload.upload" method="post" style="float: left;">');
		  htp.p(fun.lang('Arquivo para upload')||': <input type="file" name="arquivo" style="max-width: 330px; border: inherit; border-radius: 0;" data-arquivo="" onchange="this.setAttribute(''data-arquivo'', this.value.replace(/\\/g, ''|''));">');
          
            if length(prm_alternativo) > 0 then
                htp.p('<input type="hidden" name="prm_usuario" style="display: none;" value="'||prm_alternativo||'">');
            else
                htp.p('<input type="hidden" name="prm_usuario" style="display: none;" value="">');
            end if;

			/*
              htp.p('<form enctype="multipart/form-data" action="http://integrador.upquery.com/ctb/dwu.agentc.upload" method="post" style="float: left;">');
		      tp.p(fun.lang('Arquivo para upload')||': <input type="file" name="p_documento" style="max-width: 330px; border: inherit; border-radius: 0;" data-arquivo="" onchange="this.setAttribute(''data-arquivo'', this.value.replace(/\\/g, ''|''));">');
          
              if length(prm_alternativo) > 0 then
                htp.p('<input type="hidden" name="prm_usuario" style="display: none;" value="'||prm_alternativo||'">');
              else
                htp.p('<input type="hidden" name="prm_usuario" style="display: none;" value="">');
              end if;
			*/

		  htp.p('<input type="submit" value="Upload" style="border: 1px solid #777; border-radius: 0; background: #E1E1E1; height: 24px;" >');
		  htp.p('</form>');
 
            if length(prm_alternativo) > 0 then
                for i in(select column_value from table(fun.vpipe((prm_alternativo)))) loop
                    ws_count := ws_count+1;
                    if ws_count = 1 then
                        ws_coluna := i.column_value;
                    else
                        ws_tabela := i.column_value;
                    end if;
                end loop;
                /*if(fun.cdesc(ws_tabela, ws_coluna) <> ws_coluna) then
                    htp.p('<div style="float: right; height: 30px; line-height: 30px; font-weight: bold;">ARQUIVOS DO USU�RIO: '||fun.cdesc(ws_tabela, ws_coluna)||'</div>');
                end if;*/
            end if;

		  htp.bodyclose;
		  htp.htmlclose;
    end main;
	
PROCEDURE upload (arquivo  IN  VARCHAR2, prm_usuario varchar2 default null ) AS
		  
  l_nome_real  VARCHAR2(1000);
  ws_usuario   varchar2(80);
  ws_nofile    exception;

	BEGIN

    if nvl(arquivo, 'N/A') = 'N/A' then
      raise ws_nofile;
    end if;

      
    ws_usuario := nvl(prm_usuario, gbl.getUsuario);

    if gbl.getNivel = 'A' and nvl(prm_usuario, 'N/A') = 'N/A' then
      ws_usuario := 'DWU';
    end if;

		HTP.htmlopen;
		HTP.headopen;
		HTP.title(fun.lang('Arquivo Carregado'));
		HTP.headclose;
		HTP.bodyopen;
    htp.p(nvl(arquivo, 'N/A'));
		HTP.header(1, 'STATUS');

    l_nome_real := lower(replace(SUBSTR(arquivo, INSTR(arquivo, '/') + 1), ' ', '_'));

    BEGIN

    DELETE FROM dwu.TAB_DOCUMENTOS
    WHERE  trim(lower(name)) = l_nome_real and
    usuario = 'DWU';

    UPDATE dwu.TAB_DOCUMENTOS
    SET    name = l_nome_real,
    usuario = coalesce(ws_usuario, prm_usuario, 'DWU')
    WHERE  name = arquivo;

    htp.p('<script>parent.alerta(''msg'', '''||fun.lang('Arquivo enviado com sucesso')||'!''); if(parent.document.getElementById(''browseredit'')){ var valor = parent.document.getElementById(''browseredit'').className; parent.ajax(''list'', ''anexo'', ''prm_chave=''+valor, false, ''editb'', '''', '''', ''bro''); } else { parent.ajax(''list'', ''uploaded'', ''prm_chave='||prm_usuario||''', false, ''content'');  parent.carregaPainel(''upload'', '''||prm_usuario||'''); }</script>');
	EXCEPTION 
    when ws_nofile then
      htp.p('NENHUM ARQUIVO SELECIONADO!');
    WHEN OTHERS THEN
			htp.p(fun.lang('Carregado ') || l_nome_real || fun.lang(' ERRO.'));
			htp.p(SQLERRM);
	END;
END upload;

PROCEDURE download IS
  l_nome  VARCHAR2(255);
BEGIN
    /*fcl.refresh_Session;*/
  l_nome := SUBSTR(OWA_UTIL.get_cgi_env('PATH_INFO'), 2);
  WPG_DOCLOAD.download_file(l_nome);
EXCEPTION
  WHEN OTHERS THEN
    HTP.htmlopen;
    HTP.headopen;
    HTP.title(fun.lang('Arquivo Carregado.'));
    HTP.headclose;
    HTP.bodyopen;
    HTP.header(1, 'STATUS');
    HTP.print('Carregado ' || l_nome || ' ERRO.');
    HTP.print(SQLERRM);
    HTP.bodyclose;
    HTP.htmlclose;
END download;

Procedure Download ( arquivo  In  Varchar2 ) As
  L_Blob_Content  Tab_Documentos.Blob_Content%Type;
  l_mime_type     TAB_DOCUMENTOS.mime_type%TYPE;

  n_name          varchar2(4000);

BEGIN
    /*fcl.refresh_Session;*/
  SELECT blob_content,
         mime_type,
		 name
  INTO   l_blob_content,
         L_Mime_Type,
		 n_name
  From   Tab_Documentos
  WHERE  name = arquivo and (usuario = 'DWU' or usuario = 'SYS');

  OWA_UTIL.mime_header(l_mime_type, FALSE);
  HTP.p('Content-Length: ' || DBMS_LOB.getlength(l_blob_content));
  HTP.p('Content-Disposition: filename="'||n_name||'"');
  OWA_UTIL.http_header_close;

  WPG_DOCLOAD.download_file(l_blob_content);
EXCEPTION
  WHEN OTHERS THEN
    HTP.htmlopen;
    HTP.headopen;
    HTP.title('ARQUIVO');
    HTP.headclose;
    HTP.bodyopen;
    HTP.header(1, 'ERRO');
    HTP.print(SQLERRM);
    HTP.bodyclose;
    HTP.htmlclose;
End Download;
	
end upload;
/
show error
exit