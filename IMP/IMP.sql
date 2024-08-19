set scan off

create or replace package IMP IS
	
	 PROCEDURE IMPORT_TEST ( PRM_ARQUIVO     VARCHAR2 DEFAULT NULL,
	                         PRM_TABELA      VARCHAR2 DEFAULT NULL,
	                        -- PRM_USUARIO     VARCHAR2 DEFAULT 'DWU',
	                         --PRM_COMMA       VARCHAR2 DEFAULT NULL,
	                         --PRM_DECIMAL     VARCHAR2 DEFAULT NULL,
	                         PRM_CABECALHO   VARCHAR2 DEFAULT '0',
	                         PRM_ACAO        VARCHAR2 DEFAULT NULL );

     PROCEDURE IMPORT_XLS ( PRM_ARQUIVO    VARCHAR2 DEFAULT NULL,
	                       PRM_TABELA      VARCHAR2 DEFAULT NULL,
	                       PRM_USUARIO     VARCHAR2 DEFAULT 'DWU',
	                       PRM_COMMA       VARCHAR2 DEFAULT NULL,
	                       PRM_DECIMAL     VARCHAR2 DEFAULT NULL,
                           PRM_CABECALHO   VARCHAR2 DEFAULT '0' );
    
    PROCEDURE MAIN ( PRM_MODELO VARCHAR2 DEFAULT NULL,
                     PRM_TABELA VARCHAR2 DEFAULT NULL);
    
    PROCEDURE IMPORT_CABECALHO ( prm_modelo varchar2 default null,
								 PRM_ARQUIVO   VARCHAR2 DEFAULT NULL, 
		                         PRM_TABELA    VARCHAR2 DEFAULT NULL, 
		                         PRM_CABECALHO VARCHAR2 DEFAULT NULL, 
		                         PRM_ACAO      VARCHAR2 DEFAULT NULL,
		                         PRM_EVENTO    VARCHAR2 DEFAULT NULL );
    
    PROCEDURE IMPORT_CHANGE ( prm_modelo  VARCHAR2 DEFAULT NULL,
							  PRM_NUMERO  NUMBER   DEFAULT NULL,
							  PRM_NOME    VARCHAR2 DEFAULT NULL,
							  PRM_DESTINO VARCHAR2 DEFAULT NULL,
							  PRM_TIPO    VARCHAR2 DEFAULT 'varchar2',
							  PRM_TRFS    VARCHAR2 DEFAULT NULL,
							  PRM_replacein    VARCHAR2 DEFAULT NULL,
							  PRM_replaceout    VARCHAR2 DEFAULT NULL,
							  PRM_mascara    VARCHAR2 DEFAULT NULL,
							  PRM_OP      VARCHAR2 DEFAULT NULL );
							  --PRM_ID      NUMBER   DEFAULT NULL );

	procedure importDelete ( prm_modelo varchar2 default null );
    
    PROCEDURE EXECUTENOW ( PRM_COMANDO  VARCHAR2 DEFAULT NULL );

END IMP;
/
create or replace package body IMP is


	procedure import_test (  prm_arquivo     varchar2 default null,
							 prm_tabela      varchar2 default null,
							 --prm_usuario   varchar2 default 'DWU',
							 --prm_comma     varchar2 default null,
							 --prm_decimal   varchar2 default null,
							 prm_cabecalho   varchar2 default '0',
							 prm_acao        varchar2 default null) as
						
						
	    ws_count            number;
	    ws_counter          number;
	    ws_minus            number;  
	    ws_insert_format    varchar2(8000);
	    ws_create           varchar2(8000);
	    ws_lista            varchar2(4000);
	    ws_erro             varchar2(4000);
	    ws_linha            varchar2(4000);
	    ws_import_err       exception;
	    ws_semmodelo        exception;
	    ws_errocoluna       exception;
	    ws_date             date;
		ws_tabela			varchar2(200);

        begin

			ws_date := sysdate;
			
			select nm_tabela into ws_tabela from modelo_cabecalho where upper(nm_modelo) = upper(prm_tabela); 
			
			-- Verifica se já existe uma tabela com o mesmo nome no banco;
			select count(*) into ws_count from all_tables where upper(table_name) = upper(ws_tabela); 
			
			if ws_count = 0 then

			   select count(*) into ws_count from modelo_coluna where upper(nm_modelo) = upper(prm_tabela);
			   
			   
			   if ws_count <> 0 then
			   
			   select listagg(NM_COLUNA||' '||DECODE(upper(TP_COLUNA), 'VARCHAR2', 'VARCHAR2(200)', TP_COLUNA), ', ') within group
			   (order by NR_COLUNA) NM_COLUNA into ws_lista from modelo_coluna where upper(nm_modelo) = upper(prm_tabela) order by nr_coluna;
			   
			   ws_create := 'create table '||upper(ws_tabela)||'('; 
			   
			   ws_create := ws_create||ws_lista;
			   
			   ws_create := ws_create||')';
			  
			   execute immediate (ws_create);
			   
			   commit;
			   
			   else
			   
				   raise ws_semmodelo;
			   
			   end if;

			else

			    select count(*) into ws_minus from (
				    select column_name from all_tab_columns where table_name = upper(ws_tabela) 
			    minus
			    select nm_coluna from modelo_coluna where nm_modelo = upper(prm_tabela)
			    );

				if ws_minus = 0 then
				--Começa a verificação de colunas;
					select count(*) into ws_minus from (
					select nm_coluna from modelo_coluna where nm_modelo = upper(prm_tabela)
					minus
					select column_name from all_tab_columns where table_name = upper(ws_tabela) 
					);

					if ws_minus <> 0 then
					   raise ws_errocoluna;
					end if;

				else
				   raise ws_errocoluna;
				end if;

				if prm_acao = 'DELETE' then
				
				    ws_create := 'delete from '||upper(ws_tabela)||''; 
				   
				   execute immediate (ws_create);
				   
				end if;

				select count(*) into ws_count from modelo_coluna where upper(nm_modelo) = upper(prm_tabela);
				   
				if ws_count = 0 then
				   
				    ws_counter := 0;
				   
				    for i in (select column_name, data_type from all_tab_columns where upper(table_name) = upper(ws_tabela)) loop 
					   ws_counter := ws_counter+1;
					   insert into modelo_coluna (id_coluna, nm_modelo, nr_coluna, nm_coluna, nm_destino, tp_coluna, trfs_coluna) values (ws_counter, upper(prm_tabela), ws_counter, i.column_name, i.column_name, lower(i.data_type), '');
				    end loop;
				    commit;
				   
				end if;
				   
			end if;

			import_xls ( lower(prm_arquivo), prm_tabela, '', '', '', prm_cabecalho);

			exception
			    when ws_errocoluna then
				htp.p('FAIL 1'||fun.lang('N&uacute;mero ou nome de colunas do modelo n&atilde;o respeitam as da tabela do banco de dados'));
			when ws_semmodelo then
				htp.p('FAIL 2'||fun.lang('Importa&ccedil;&atilde;o precisa no m&iacute;nimo de um modelo de colunas ou uma tabela selecionada'));
			when ws_import_err then
				Insert Into bi_log_sistema Values(Sysdate , DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - IMPORT' , user , 'ERRO');
				commit;
				htp.p('FAIL 3');
			when others then
				Insert Into bi_log_sistema Values(Sysdate , DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - IMPORT' , user , 'ERRO');
				commit;
				htp.p('FAIL 4');
    end import_test;








    procedure import_xls ( prm_arquivo     varchar2 default null,
						   prm_tabela      varchar2 default null,
						   prm_usuario     varchar2 default 'DWU',
						   prm_comma       varchar2 default null,
						   prm_decimal     varchar2 default null,
						   prm_cabecalho   varchar2 default '0' ) as
		
		ws_usuario        	varchar2(300); 
		ws_usuario_arquivo 	varchar2(300); 
		ws_nome_arquivo     varchar2(300);

		cursor c_localiza_arquivo  is 
			select name, usuario, blob_content 
			  from tab_documentos 
			 where lower(name) in ( replace(lower(prm_arquivo), '.xlsx', '')||'.xlsx', replace(lower(prm_arquivo), '.ods', '')||'.ods' ) 
			   and usuario in ('DWU','ANONYMOUS', ws_usuario ) ; 

		cursor crs_seq ( p_nome varchar2,  p_usuario  varchar2) is
			 Select '1' as X,
					cell_type, cell,
					decode(cell_type,'S',string_val,'D',date_val,'N',number_val,'') conteudo,
					row_nr, col_nr
			  from Table( as_read_xlsx.Read( (Select Blob_Content From tab_documentos 
				                               Where name    = p_nome 
										         and usuario = p_usuario ), 1 ) ) 
			 where nvl(sheet_nr,1) = 1
			 order by row_nr, col_nr;

		cursor c_colunas  is
			select * from MODELO_COLUNA
			where upper(nm_modelo) = upper(prm_tabela)
			order by nr_coluna;

		cursor c_mod_col (p_nr_coluna  number ) is
			select * from MODELO_COLUNA
			where upper(nm_modelo) = upper(prm_tabela)
			  and nr_coluna        = p_nr_coluna ;

        type ws_tmcolunas is table of MODELO_COLUNA%ROWTYPE
        index by pls_integer;


		ws_row_ant          number;
		ws_insert_format    varchar2(4000);
		ws_create           varchar2(8000);
		ws_lista            varchar2(6000);
		ws_erro             varchar2(6000);
		ws_linha            varchar2(26000);
		ws_transform        varchar2(400);
		ws_replacein        varchar2(400);
		ws_replaceout       varchar2(400);
		ws_mascara          varchar2(400);
		ws_col              number;
		ws_virgula          varchar2(10);
		ws_valor            varchar2(400);
		ws_tabela			varchar2(200);
		ws_cell             varchar2(10); 

		ws_qt_ins  			number;
		ws_qt_arquvos       number;
		ws_arquivo 			blob;

		Ws_Seq        Crs_Seq%Rowtype;
		wt_mod_col    c_mod_col%Rowtype; 

		ws_valida_number    	number;
		ws_valida_date      	date; 

		ws_erro_insert			exception;
		ws_erro_conteudo_arq    exception;
		ws_erro_conteudo_cel	exception;



		begin

            ws_usuario := gbl.getUsuario; 

			select nm_tabela into ws_tabela from modelo_cabecalho where upper(nm_modelo) = upper(prm_tabela); 

     		ws_qt_arquvos := 0;
			for a in c_localiza_arquivo loop 
				ws_qt_arquvos		:= ws_qt_arquvos + 1 ;
				ws_nome_arquivo     := a.name ; 
				ws_usuario_arquivo	:= a.usuario; 
				ws_arquivo      	:= a.blob_content;
			end loop; 

			if ws_qt_arquvos = 1 then

				insert into bi_log_sistema values(sysdate , 'COME&Ccedil;O DA IMPORTA&Ccedil;&Atilde;O('||upper(prm_tabela)||')', user, 'EVENTO');
				commit;

				-- Monta a clausula do INSERT com as colunas do modelo e monta arrays   ws_item_array e ws_item_type
				-------------------------------------------------------------------------------------------------------
				ws_insert_format := ''; 
				ws_virgula       := '';
				for a in c_colunas loop 
					ws_insert_format := ws_insert_format||ws_virgula||a.nm_coluna;
					ws_virgula       := ',';
				end loop; 
				ws_insert_format := 'insert into '||ws_tabela||' ('||ws_insert_format||') values ('; 



				-- Monta os dados de cada linha do arquivo e executa o insert na tabela 
				-------------------------------------------------------------------------------------------------------
				ws_qt_ins  := 0;
				ws_linha   := '';  -- Linha a variável linha para montar com a próxima linha do arquivo 
				ws_virgula := '';
				ws_col     := 0;
                ws_row_ant := 0; 
				ws_cell    := null; 

				Open Crs_Seq(ws_nome_arquivo, ws_usuario_arquivo);
				Loop
					Fetch Crs_Seq Into Ws_Seq;
					Exit When Crs_Seq%Notfound;

					if ws_seq.row_nr is null then 
					   ws_valor := ws_seq.conteudo;
		               raise ws_erro_conteudo_arq; 
					end if; 

					ws_cell := ws_seq.cell; 
					if ws_seq.row_nr > prm_cabecalho then   -- linhas ignoradas do arquivo (cabeçalho)

						-- Insere o registro montado com todas as colunas da linha anterior (quando chega na próxima linha do arquivo) 
						--------------------------------------------------------------------------------------------------------------------------
						if ws_row_ant <> Ws_Seq.row_nr and ws_seq.row_nr > (prm_cabecalho + 1)  then  
							begin
								ws_qt_ins := ws_qt_ins + 1;
								execute immediate (ws_insert_format||ws_linha||')');
							exception
								when others then
								raise ws_erro_insert;
							end;
							ws_linha   := '';  -- Linha a variável linha para montar com a próxima linha do arquivo 
							ws_virgula := '';
							ws_col     := 0;
						end if ;


						-- Monta a linha com os dados a serem inseridos  
						--------------------------------------------------------------------------------------------------------------------------
						ws_col		:= ws_col + 1;
						wt_mod_col	:= null;
						open  c_mod_col(ws_col);
						fetch c_mod_col into wt_mod_col;
						close c_mod_col; 
                            
						if wt_mod_col.nr_coluna is not null then   -- Se o número da coluna existe no modelo, se não existe ignora a coluna do arquivo 

								wt_mod_col.tp_coluna := nvl(lower(wt_mod_col.tp_coluna),'N/A'); 
								ws_valor 			 := replace(Ws_Seq.conteudo, chr(39), '');                              -- Retira aspas simples do conteudo da coluna 
								ws_valor 			 := replace(ws_valor, wt_mod_col.replacein, wt_mod_col.replaceout);     -- substitui do replacein por replaceout
								
								if nvl(trim(wt_mod_col.trfs_coluna), 'N/A') <> 'N/A' then -- Se tem transformação cadastrada, faz a transformação com a mascara 
									begin
										ws_valor := chr(39)||trim(to_char(ws_valor, wt_mod_col.mascara))||chr(39);    -- Tenta aplicar a máscara, se foi informado 
									exception when others then
										ws_valor := chr(39)||ws_valor||chr(39);
									end;
								else 	-- Faz as conversões conforme o tipo de dado 
									if wt_mod_col.tp_coluna = 'null' then
										ws_valor := 'NULL';
									end if;

									if  wt_mod_col.tp_coluna = 'number' then
										ws_valor := replace(nvl(ws_valor, 0),',','.');    -- Se for número substitui virgula por ponto 
										begin 
										   ws_valida_number := ws_valor;
										exception when others then 
										   raise ws_erro_conteudo_cel; 
										end;   
									end if;

									if  wt_mod_col.tp_coluna = 'varchar2' then
										if nvl(wt_mod_col.mascara, 'N/A') <> 'N/A' then  -- Tenta aplicar a máscara, se foi informado 
											begin
												ws_valor := chr(39)||trim(to_char(ws_valor, wt_mod_col.mascara))||chr(39);
											exception when others then
												ws_valor := chr(39)||ws_valor||chr(39);
											end;
										else
											ws_valor := chr(39)||ws_valor||chr(39);
										end if;
									end if;

									if  wt_mod_col.tp_coluna = 'date' then
										begin
										    if nvl(wt_mod_col.mascara, 'N/A') <> 'N/A' then    -- Tenta aplicar a máscara, se foi informado 
												ws_valida_date := to_date(trim(ws_valor), wt_mod_col.mascara); 
												ws_valor := 'to_date('||trim(ws_valor)||', '''||wt_mod_col.mascara||''')';
											else 
												ws_valida_date := to_date(trim(ws_valor)); 
												ws_valor := 'to_date('||ws_valor||')';
											end if; 	
										exception when others then 
											raise ws_erro_conteudo_cel; 
										end; 	
									end if;
								end if;

								ws_linha   := ws_linha||ws_virgula||ws_valor;
								ws_virgula := ',';
						end if;
						
					end if;

					ws_row_ant := Ws_Seq.row_nr;
				End Loop;
				close Crs_Seq;

				-- Insere a ultima linha do arquivo 
				begin
					ws_qt_ins := ws_qt_ins + 1;
					execute immediate (ws_insert_format||ws_linha||')');
				exception
					when others then
					raise ws_erro_insert;
				end;

				commit;  -- COMMIT APLICADO PARA O INSERT COMPLETO DAS LINHAS DO EXCEL. 17/02/2022

				insert into bi_log_sistema values(sysdate, 'FIM DA IMPORTA&Ccedil;&Atilde;O('||upper(prm_tabela)||'). Registros importados: '||ws_qt_ins||', total de linhas do arquivo:'||ws_row_ant, user , 'EVENTO');
				commit;
			else
				insert into bi_log_sistema values(sysdate, 'N&uacute;mero inv&aacute;lido de arquivos #'||ws_qt_arquvos, user , 'import_xls');
				commit;
				if ws_qt_arquvos = 0 then 
					htp.p('FAIL Arquivo com nome <'||ws_nome_arquivo||'> n&atilde;o localizado no sistema');
				else 	
					htp.p('FAIL Existe mais de um arquivo no sistema com o nome <'||ws_nome_arquivo||'>');
				end if; 
			end if;
		exception
			when ws_erro_insert then
				ROLLBACK;
				insert into bi_log_sistema values(sysdate , 'Erro ao inserir linha <'||ws_row_ant||'> da arquivo. '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - '||ws_insert_format||ws_linha||')', user, 'ERRO');
				commit;
			    htp.p('FAIL Erro importando linha ' ||ws_row_ant||', verifique o conte&uacute;do do arquivo ou a configura&ccedil;&atilde;o da importa&ccedil;&atilde;o do modelo');				
			when ws_erro_conteudo_arq then
				ROLLBACK;
				insert into bi_log_sistema values(sysdate , 'Conteúdo do arquivo não reconhecido como XLSX. Erro package AR_READ_XLSX.READ: '||ws_valor, user, 'ERRO');
				commit;
			    htp.p('FAIL Formato de arquivo inv&aacute;lido, para importa&ccedil;&atilde;o o arquivo deve estar no formato MS-Excel (.xlsx)');			
			when ws_erro_conteudo_cel then
				ROLLBACK;
				insert into bi_log_sistema values(sysdate , 'Erro na importação da linha '||ws_row_ant||' coluna '||ws_col||' convertendo conte&uacute;do <'||ws_valor||'> para '||upper(wt_mod_col.tp_coluna), user, 'ERRO');
				commit;
			    htp.p('FAIL Erro na importa&ccedil;&atilde;o da linha '||ws_row_ant||' coluna '||ws_col||' convertendo conte&uacute;do <'||ws_valor||'> para '||upper(wt_mod_col.tp_coluna) );			
			when others then
				insert into bi_log_sistema values(sysdate , 'Erro importação arquivo, linha: '||ws_row_ant||', coluna: '||ws_col||'. '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - '||ws_insert_format||ws_linha, user, 'ERRO');
				commit;
				htp.p('FAIL Erro importando linha '||ws_row_ant||' coluna '||ws_col||', verifique o conte&uacute;do da celula ou a configura&ccedil;&atilde;o da importa&ccedil;&atilde;o');
	end import_xls;





    /********* 
	procedure import_xls ( prm_arquivo     varchar2 default null,
						   prm_tabela      varchar2 default null,
						   prm_usuario     varchar2 default 'DWU',
						   prm_comma       varchar2 default null,
						   prm_decimal     varchar2 default null,
						   prm_cabecalho   varchar2 default '0' ) as


		cursor crs_seq ( ws_arquivo_nome varchar2 ) is
				 Select '1' as X,
						cell_type,
						decode(cell_type,'S',string_val,'D',date_val,'N',number_val,'') conteudo,
						row_nr, col_nr
				 From   Table( as_read_xlsx.Read( (Select Blob_Content From tab_documentos Where rownum = 1 and lower(name) Like lower(ws_arquivo_nome)||'%' and (usuario = 'DWU' or usuario = gbl.getUsuario or usuario = 'ANONYMOUS')), 1 ) ) 
						where sheet_nr=1
				 order  by row_nr, col_nr;

		cursor nc_colunas is
			select * from MODELO_COLUNA
			where upper(nm_modelo) = upper(prm_tabela)
			order by nr_coluna;

        type ws_tmcolunas is table of MODELO_COLUNA%ROWTYPE
        index by pls_integer;

		ret_mcol      ws_tmcolunas;
		Ws_Seq        Crs_Seq%Rowtype;

		TYPE v_array        is table of number
		index by  pls_integer;
		ws_item_array       v_array;

		TYPE v_types        is table of varchar2(400)
		index by  pls_integer;
		ws_item_type        v_types;

		ws_row              varchar2(400);
		ws_insert_format    varchar2(4000);
		ws_create           varchar2(8000);
		ws_lista            varchar2(6000);
		ws_erro             varchar2(6000);
		ws_linha            varchar2(26000);
		ws_transform        varchar2(400);
		ws_replacein        varchar2(400);
		ws_replaceout       varchar2(400);
		ws_mascara          varchar2(400);
		ws_col              number;
		ws_cont             number;
		ws_ct               number;
		ws_virgula          varchar2(10);
		ws_import_err       exception;
		ws_valor            varchar2(400);
		ws_tabela			varchar2(200);
		ws_erro2			exception;
		ws_erro1			exception;	

		ws_conteudo   DBMS_SQL.VARCHAR2_TABLE;

		ws_count   number;
		ws_counter number;
		ws_teste   number;

		ws_arquivo blob;

		ws_errcount number;

		begin

			select nm_tabela into ws_tabela from modelo_cabecalho where upper(nm_modelo) = upper(prm_tabela); 
			
			select count(*) into ws_teste from tab_documentos where lower(name) = replace(lower(prm_arquivo), '.xlsx', '')||'.xlsx' and (usuario = 'DWU' or usuario = gbl.getUsuario or usuario = 'ANONYMOUS'); 

			if ws_teste = 1 then

				select blob_content into ws_arquivo from tab_documentos where lower(name) = replace(lower(prm_arquivo), '.xlsx', '')||'.xlsx' and (usuario = 'DWU' or usuario = gbl.getUsuario or usuario = 'ANONYMOUS'); 

				insert into bi_log_sistema values(sysdate , 'COME&Ccedil;O DA IMPORTA&Ccedil;&Atilde;O('||upper(prm_tabela)||')', user, 'EVENTO');
				commit;

				open nc_colunas;
					loop
						fetch nc_colunas bulk collect into ret_mcol;
						exit when nc_colunas%NOTFOUND;
					end loop;
				close nc_colunas;
		 
				ws_insert_format := 'insert into '||ws_tabela||' ('; 
				ws_virgula       := '';

				ws_cont := 0;
				
				loop
					ws_cont := ws_cont + 1;
					if ws_cont > ret_mcol.COUNT then
						exit;
					end if;

					ws_insert_format := ws_insert_format||ws_virgula||' ';
					ws_insert_format := ws_insert_format||ret_mcol(ws_cont).nm_coluna;
					ws_virgula       := ',';
					ws_item_array(ret_mcol(ws_cont).nr_coluna) := 1;
					ws_item_type (ret_mcol(ws_cont).nr_coluna) := ret_mcol(ws_cont).tp_coluna;

				end loop;

				ws_insert_format := ws_insert_format||') values (';

				ws_ct  := 0;
				ws_row := 'FIRST_ROW';
				ws_col := 0;
				ws_count := 0;


			  Open Crs_Seq(prm_arquivo);

				Loop
					Fetch Crs_Seq Into Ws_Seq;
					Exit When Crs_Seq%Notfound;

					if ws_seq.row_nr >= prm_cabecalho then

						if (ws_row <> to_char(Ws_Seq.row_nr) and (ws_row <> 'FIRST_ROW')) or (ws_row = 'FIRST_ROW' and (prm_cabecalho = '0')) then
							ws_ct := ws_ct + 1;
							ws_virgula := '';

							if  ws_ct > 1 then

								commit;
								begin
									
									ws_count := ws_count+1;

									execute immediate (ws_insert_format||ws_linha||')');

								exception
									when others then
									raise ws_erro1;
									--raise ws_import_err;
								
								end;
								
							end if;
							
							ws_linha   := '';
							ws_col     := 0;
							ws_row := Ws_Seq.row_nr;
						end if;

						if ws_row = to_char(Ws_Seq.row_nr) or (ws_row = 'FIRST_ROW') then --and prm_cabecalho = 'S') then
						 
							ws_col := ws_col + 1;

							if  ws_item_array.exists(ws_col) then

								ws_valor := replace(Ws_Seq.conteudo, chr(39), '');

								begin

									select trim(trfs_coluna), replacein, replaceout, mascara  into ws_transform, ws_replacein, ws_replaceout, ws_mascara from MODELO_COLUNA
									where upper(nm_modelo) = upper(prm_tabela)
									and nr_coluna = ws_col;

									if instr(ws_transform, '$[SELF]') > 0 then
										ws_valor := replace(ws_transform, '$[SELF]', Ws_Seq.conteudo);
									end if;

								exception when others then
									ws_errcount := ws_errcount+1;
								end;

								ws_valor := replace(ws_valor, ws_replacein, ws_replaceout);

								if  nvl(trim(ws_transform), 'N/A') = 'N/A' then
								
									if lower(ws_item_type(ws_col)) = 'null' then
										ws_linha := ws_linha||ws_virgula||'NULL';
									end if;

									if  lower(ws_item_type(ws_col)) = 'number' then
										ws_linha := ws_linha||ws_virgula||replace(nvl(ws_valor, 0),',','.');
									end if;

									if  lower(ws_item_type(ws_col)) = 'varchar2' then

										if nvl(ws_mascara, 'N/A') <> 'N/A' then
											begin
												ws_linha := ws_linha||ws_virgula||chr(39)||trim(to_char(ws_valor, ws_mascara))||chr(39);
											exception when others then
												ws_linha := ws_linha||ws_virgula||chr(39)||ws_valor||chr(39);
											end;
										else
											ws_linha := ws_linha||ws_virgula||chr(39)||ws_valor||chr(39);
										end if;
									end if;

									if  lower(ws_item_type(ws_col)) = 'date' then

										if nvl(ws_mascara, 'N/A') <> 'N/A' then
											begin
												ws_linha := ws_linha||ws_virgula||'to_date('||trim(ws_valor)||', '''||ws_mascara||''')';
											exception when others then
												ws_linha := ws_linha||ws_virgula||chr(39)||ws_valor||chr(39);
											end;
										else
											ws_linha := ws_linha||ws_virgula||chr(39)||ws_valor||chr(39);
										end if;
									end if;


								else
									begin
										ws_linha := ws_linha||ws_virgula||chr(39)||trim(to_char(ws_valor, ws_mascara))||chr(39);
									exception when others then
										ws_linha := ws_linha||ws_virgula||chr(39)||ws_valor||chr(39);
									end;
								end if;
		 
							end if;
							ws_virgula := ',';
						end if;

						ws_row := Ws_Seq.row_nr;
					end if;
				End Loop;
			  close Crs_Seq;
				begin

					ws_count := ws_count+1;

					execute immediate (ws_insert_format||ws_linha||')');

					--htp.p(ws_insert_format||ws_linha||');');

				exception
					when others then
					raise ws_erro2;
					--raise ws_import_err;
				end;

				insert into bi_log_sistema values(sysdate, 'FIM DA IMPORTA&Ccedil;&Atilde;O('||upper(prm_tabela)||')',user , 'EVENTO');
				commit;

				if ws_errcount > 0 then
					insert into bi_log_sistema values(sysdate, 'IMPORTA&Ccedil;&Atilde;O COM '||ws_errcount||' ERROS NA TRANSFORMA&Ccedil;&Atilde;O',user , 'ERRO');
				    commit;
				end if;
			else
		   
				insert into bi_log_sistema values(sysdate, 'N&uacute;mero inv&aacute;lido de arquivos #'||ws_teste, user , 'import_xls');
				commit;
				
				htp.p('FAIL Número inválido de arquivos');

			end if;

		exception
			when ws_import_err then
				insert into bi_log_sistema values(sysdate , DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - '||ws_insert_format||ws_linha, user, 'ERRO');
				commit;
			    htp.p('FAIL Tipo da coluna inadequado ou N&uacute;mero de coluna inexistente(repetido).');
			
			when ws_erro1 then
				insert into bi_log_sistema values(sysdate , DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - '||ws_insert_format||ws_linha, user, 'ERRO');
				commit;
			    htp.p('FAIL Tipo da coluna inadequado ou N&uacute;mero de coluna inexistente(repetido).');

			when ws_erro2 then
				insert into bi_log_sistema values(sysdate , DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - '||ws_insert_format||ws_linha, user, 'ERRO');
				commit;
			    htp.p('FAIL Tipo da coluna inadequado ou N&uacute;mero de coluna inexistente(ultima linha do insert).');
			when others then
				insert into bi_log_sistema values(sysdate , DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - '||ws_insert_format||ws_linha, user, 'ERRO');
				commit;
			htp.p('FAIL Preencha todos os campos da ordem de colunas do modelo');
	end import_xls;
    ***********************/ 





	procedure main ( prm_modelo varchar2 default null,
					 prm_tabela varchar2 default null ) as

		cursor crs_colunas is
			select nm_modelo, nr_coluna, nm_coluna, nm_destino, tp_coluna, trfs_coluna, id_coluna, replacein, replaceout, mascara
			from modelo_coluna where upper(nm_modelo) = upper(nvl(prm_modelo, nm_modelo))
			
			union all
			
			select prm_modelo as nm_modelo, null as nr_coluna, column_name as nm_coluna, '' as nm_destino, '' as tp_coluna, '' as trfs_coluna,
			null as id_coluna, '' as replacein, '' as replaceout, '' as mascara
			from all_tab_columns 
			where upper(table_name) = upper(prm_modelo) and column_name not in(
				select nm_coluna from modelo_coluna where upper(nm_modelo)= upper(prm_modelo)
			)  

			order by nr_coluna, nm_modelo;
	   
		ws_coluna crs_colunas%rowtype;

	 
		cursor crs_cabecalho is
			select nm_arquivo, nm_tabela, st_cabecalho, st_acao
			from modelo_cabecalho where upper(nm_modelo) = upper(nvl(prm_modelo, nm_tabela))
			order by nm_tabela;
	   
		ws_cabecalho crs_cabecalho%rowtype;

		ws_clickcoluna varchar2(2000);
		ws_readonly varchar2(200);

		begin

			if gbl.getNivel = 'A' then
				ws_readonly := '';
			else
				ws_readonly := 'style="background: #AAA; color: #666;" readonly disabled';
			end if;

			htp.p('<select id="import-tabela-ut" style="float: right; margin: 10px 10px 0 0;" onchange="call(''main'', ''prm_modelo=''+this.value, ''imp'').then(function(resposta){ document.getElementById(''content'').innerHTML = resposta; });">');
			htp.p('<option value="" readonly>'||fun.lang('Selecione uma importa&ccedil;&atilde;o')||'</option>');
			
			for i in(select distinct nm_modelo from modelo_cabecalho where nm_modelo is not null order by nm_modelo asc) loop

				if upper(i.nm_modelo) = prm_modelo then
					htp.p('<option value="'||upper(i.nm_modelo)||'" selected>'||upper(i.nm_modelo)||'</option>');
				else
					htp.p('<option value="'||upper(i.nm_modelo)||'">'||upper(i.nm_modelo)||'</option>');
				end if;
			end loop;    
			htp.p('</select>');


		if nvl(prm_modelo, 'N/A') <> 'N/A' then
			
			open crs_cabecalho;
				loop
					fetch crs_cabecalho into ws_cabecalho;
					exit when crs_cabecalho%notfound;
				end loop;
			close crs_cabecalho;

				htp.p('<h4 style="margin: 16px 2px;">'||fun.lang('CONFIGURA&Ccedil;&Atilde;O DA IMPORTA&Ccedil;&Atilde;O')||'</h4>');

				htp.p('<label style="font-size: 10px; font-weight: bold; font-family: ''montserrat'';">'||fun.lang('ARQUIVO')||': </label>');
				htp.p('<a class="script" onclick="call(''import_cabecalho'', ''prm_arquivo=''+document.getElementById(''import-arquivo-ut'').title.replace(''dwu.fcl.download?arquivo='', '''').replace(''.xlsx'', '''')+''&prm_tabela=''+document.getElementById(''import-tabela-ut'').value+''&prm_cabecalho=''+document.getElementById(''import-cabecalho-ut'').value+''&prm_acao=''+document.getElementById(''import-acao-ut'').value+''&prm_evento=ARQUIVO'', ''imp'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_AL); } else { alerta(''feed-fixo'', TR_ER); }  });"></a>');
				fcl.fakeoption('import-arquivo-ut', ws_cabecalho.nm_arquivo, ws_cabecalho.nm_arquivo, 'lista-xls', 'N', 'N');

				htp.p('<label style="font-size: 10px; font-weight: bold; font-family: ''montserrat'';">'||fun.lang('LINHAS IGNORADAS')||': </label>');
				htp.p('<input type="text" id="import-cabecalho-ut" onkeypress="return input(event, ''integer'');" onblur="call(''import_cabecalho'', ''prm_arquivo=''+document.getElementById(''import-arquivo-ut'').title.replace(''dwu.fcl.download?arquivo='', '''').replace(''.xlsx'', '''')+''&prm_tabela=''+document.getElementById(''import-tabela-ut'').value+''&prm_cabecalho=''+document.getElementById(''import-cabecalho-ut'').value+''&prm_acao=''+document.getElementById(''import-acao-ut'').value+''&prm_evento=CABECALHO'', ''imp'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_AL); } else { alerta(''feed-fixo'', TR_ER); }  });" value="'||ws_cabecalho.st_cabecalho||'" />');

				
				htp.p('<label style="font-size: 10px; font-weight: bold; font-family: ''montserrat'';">'||fun.lang('A&Ccedil;&Atilde;O')||': </label><select id="import-acao-ut" onchange="call(''import_cabecalho'', ''prm_arquivo=''+document.getElementById(''import-arquivo-ut'').title.replace(''dwu.fcl.download?arquivo='', '''').replace(''.xlsx'', '''')+''&prm_tabela=''+document.getElementById(''import-tabela-ut'').value+''&prm_cabecalho=''+document.getElementById(''import-cabecalho-ut'').value+''&prm_acao=''+document.getElementById(''import-acao-ut'').value+''&prm_evento=ACAO'', ''imp'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_AL); } else { alerta(''feed-fixo'', TR_ER); }  });">');
				if ws_cabecalho.st_acao = 'ADD' then
					htp.p('<option value="ADD" selected>ADICIONAR A TABELA</option>');
					htp.p('<option value="DELETE">LIMPAR TABELA E ADICIONAR</option>');
				else
					htp.p('<option value="ADD">ADICIONAR A TABELA</option>');
					htp.p('<option value="DELETE" selected>LIMPAR TABELA E ADICIONAR</option>');
				end if;
				htp.p('</select>');

				if nvl(prm_modelo, 'N/A') <> 'N/A' then
					htp.p('<label style="font-size: 10px; font-weight: bold; font-family: ''montserrat'';">TABELA: </label>');
					htp.p('<input type="text" readonly class="readonly" value="'||ws_cabecalho.nm_tabela||'">');
				end if;

				htp.p('<table class="linha">');
					htp.p('<thead>');
					htp.p('<tr>');
					htp.p('<th>'||fun.lang('COLUNA')||'</th>');
					htp.p('<th title="Ordem das colunas precisam ser as mesmas tanto na tabela quanto no arquivo">'||fun.lang('ORDEM DA COLUNA')||'</th>');
					htp.p('<th>'||fun.lang('TIPO')||'</th>');
					htp.p('<th colspan="1"></th>');
					htp.p('<th colspan="2" style="text-align: center;">SUBSTITUIR</th>');
					htp.p('<th colspan="2"></th>');
					htp.p('</tr>');
					htp.p('</thead>');

					htp.p('<tbody>');

						open crs_colunas;
							loop
								fetch crs_colunas into ws_coluna;
								exit when crs_colunas%notfound;
								
								htp.p('<tr>');

									htp.p('<td>');
										htp.p('<input readonly class="readonly" value="'||ws_coluna.nm_coluna||'" />');
									htp.p('</td>');

									htp.p('<td>');
										htp.p('<input '||ws_readonly||' data-default="'||ws_coluna.nr_coluna||'" onblur="importEditColumn(this, '''||ws_coluna.nm_modelo||''');" type="number" value="'||ws_coluna.nr_coluna||'" />');
									htp.p('</td>');

									htp.p('<td style="width: 120px;">');

										htp.p('<select '||ws_readonly||' style="width: 120px;" onchange="importEditColumn(this, '''||ws_coluna.nm_modelo||''');">');
											if ws_coluna.tp_coluna = 'varchar2' then
												htp.p('<option value="varchar2" selected>VARCHAR2</option>');
											else
												htp.p('<option value="varchar2">VARCHAR2</option>');
											end if;

											if ws_coluna.tp_coluna = 'number' then
											htp.p('<option value="number" selected>NUMBER</option>');
											else
												htp.p('<option value="number">NUMBER</option>');
											end if;

											/*if ws_coluna.tp_coluna = 'date' then
												htp.p('<option value="date" selected>DATA</option>');
											else
												htp.p('<option value="date">DATA</option>');
											end if;*/

											if ws_coluna.tp_coluna = 'null' then
												htp.p('<option value="null" selected>NULL</option>');
											else
												htp.p('<option value="null">NULL</option>');
											end if;
										htp.p('</select>');
												
									htp.p('</td>');

									htp.p('<td style="width: 128px;">');
										htp.p('<input type="text" onblur="importEditColumn(this, '''||ws_coluna.nm_modelo||''');" value="'||ws_coluna.trfs_coluna||'" placeholder="TRANSFORMA&Ccedil;&Atilde;O" title="$[SELF] retorna o valor da coluna"/>');
									htp.p('</td>');

									htp.p('<td style="width: 80px;">');
										htp.p('<input type="text" onblur="importEditColumn(this, '''||ws_coluna.nm_modelo||''');" placeholder="ENTRADA" style="text-transform: uppercase; width: 80px;" value="'||ws_coluna.replacein||'" title="" />');
									htp.p('</td>');

									htp.p('<td style="width: 80px;">');
										htp.p('<input type="text" onblur="importEditColumn(this, '''||ws_coluna.nm_modelo||''');" placeholder="SA&Iacute;DA" style="text-transform: uppercase; width: 80px;" value="'||ws_coluna.replaceout||'" title="" />');
									htp.p('</td>');

									htp.p('<td style="width: 80px;">');
										htp.p('<input type="text" onblur="importEditColumn(this, '''||ws_coluna.nm_modelo||''');" placeholder="M&Aacute;SCARA" style="text-transform: uppercase; width: 80px;" value="'||ws_coluna.mascara||'" title="" />');
									htp.p('</td>');
					
									htp.p('<td class="noborder">');
										if user = 'DWU' then
											htp.p('<a class="remove" title="'||fun.lang('excluir')||'" onclick="var row = this.parentNode.parentNode; if(confirm(TR_CE)){ call(''import_change'', ''prm_modelo='||ws_coluna.nm_modelo||'&prm_numero=''+document.getElementById('''||ws_coluna.nm_modelo||'-'||ws_coluna.id_coluna||'-numero'').value+''&prm_nome=&prm_destino=&prm_tipo=&prm_trfs=''+document.getElementById('''||ws_coluna.nm_modelo||'-'||ws_coluna.id_coluna||'-trfs'').value+''&prm_op=DELETE&prm_id='||ws_coluna.id_coluna||''', ''imp'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_EX); row.remove(); call(''main'', ''prm_modelo=''+document.getElementById(''import-tabela-ut'').value, ''imp'').then(function(resposta){ document.getElementById(''content'').innerHTML = resposta; }); }  });}">X</a>');
										else
											htp.p('<a class="noremove">X</a>');
										end if;
									htp.p('</td>');

								htp.p('</tr>');
							end loop;
						close crs_colunas;
					htp.p('</tbody>');
				htp.p('</table>');

			htp.p('<a class="rel_button" style="position: relative !important; font-weight: bold; font-family: ''montserrat''; border-radius: 2px; background: linear-gradient(#EFEFEF, #FFF); padding: 10px; border: 1px solid #999; font-size: 20px; letter-spacing: 0.5px; margin: 20px auto 0 auto; display: block; width: 254px; text-align: center;" onclick="importGenerateData(this);">IMPORTAR DADOS</a>');

			if gbl.getNivel = 'A' then
				htp.p('<a class="exclude" title="" onclick="if(confirm(TR_CE)){ call(''importDelete'', ''prm_modelo=''+get(''import-tabela-ut'').value, ''imp'').then(function(res){ if(res.indexOf(''ok'') != -1){ alerta(''feed-fixo'', TR_EX); call(''main'', ''prm_modelo='', ''imp'').then(function(resposta){ document.getElementById(''content'').innerHTML = resposta; }); } else { alerta(''feed-fixo'', TR_ER); } }); }"></a>');
			end if;

		end if;

	end main;

	procedure import_cabecalho ( prm_modelo    varchar2 default null,
								 prm_arquivo   varchar2 default null,
								 prm_tabela    varchar2 default null,
								 prm_cabecalho varchar2 default null,
								 prm_acao      varchar2 default null,
								 prm_evento    varchar2 default null ) as

		ws_count   number;
		ws_fail    exception;
	    ws_id      number;
	    ws_err     varchar2(80);

		begin

    case prm_evento
        when 'ARQUIVO' then

            update modelo_cabecalho
            set nm_arquivo = fun.converte(prm_arquivo)
            where upper(nm_modelo) = upper(prm_tabela);

            ws_count := SQL%ROWCOUNT;

			if ws_count <> 0 then
				commit;
			else
				raise ws_fail;
			end if;

        when 'CABECALHO' then

            update modelo_cabecalho
            set st_cabecalho = fun.converte(prm_cabecalho)
            where upper(nm_modelo) = upper(prm_tabela);
           
            ws_count := SQL%ROWCOUNT;
			
			if ws_count <> 0 then
				commit;
			else
				raise ws_fail;
			end if;

        when 'ACAO' then

            update modelo_cabecalho
            set st_acao = prm_acao
            where upper(nm_modelo) = upper(prm_tabela);

            ws_count := SQL%ROWCOUNT;

			if ws_count <> 0 then
				commit;
			else
				raise ws_fail;
			end if;

        else

            select count(*) into ws_count from modelo_cabecalho where upper(trim(prm_modelo)) = upper(trim(nm_modelo));
            if ws_count = 0 then
                insert into modelo_cabecalho ( nm_arquivo, nm_tabela, st_cabecalho, st_acao, nm_modelo) values ( fun.converte(prm_arquivo), upper(prm_tabela), prm_cabecalho, prm_acao, prm_modelo);

   				ws_count := SQL%ROWCOUNT;

   				if ws_count = 1 then
       				commit;

					ws_count := 0;
					select max(id_coluna) into ws_id from modelo_coluna;

					begin
						for i in(select column_name from all_tab_cols where table_name = upper(prm_tabela) order by column_id) loop

							ws_count := ws_count+1;
							begin
								insert into modelo_coluna ( id_coluna, nm_modelo, nr_coluna, nm_coluna, nm_destino, tp_coluna, trfs_coluna, replacein, replaceout, mascara ) values ( nvl(ws_id, 0)+ws_count, upper(prm_modelo), '', i.column_name, '', 'VARCHAR2', '', '', '', '');
								commit;
							exception when others then
								htp.p(sqlerrm);
							end;
						end loop;
					exception when others then
						htp.p(sqlerrm);
					end;

   				else
					ws_err := 'IMPOSS&Iacute;VEL ADICIONAR CABECALHO';
					raise ws_fail;
				end if;
			else
   				ws_err := 'DUPLICADO';
   				raise ws_fail;
			end if;

    	end case;

exception
    when ws_fail then
        rollback;
        htp.p('FAIL '||ws_err);
    when others then
        rollback;
        htp.p('FAIL');
end import_cabecalho;

procedure import_change ( prm_modelo     varchar2  default  null,
                          prm_numero     number    default  null,
                          prm_nome       varchar2  default  null,
                          prm_destino    varchar2  default  null,
                          prm_tipo       varchar2  default  'varchar2',
                          prm_trfs       varchar2  default  null,
						  prm_replacein  varchar2  default  null,
						  prm_replaceout varchar2  default  null,
						  prm_mascara    varchar2  default  null,
                          prm_op         varchar2  default  null ) as
 						  --prm_id         number    default  null ) as

    ws_count number;
    ws_fail  exception;
    ws_key   number;
    ws_inc   number;

begin

    if prm_op = 'DELETE' then

		delete from modelo_coluna where nm_modelo = prm_modelo and nm_coluna = prm_nome;

        ws_count := SQL%ROWCOUNT;

        if ws_count <> 0 then
            commit;
        else
            raise ws_fail;
        end if;

    else

		select count(*) into ws_count from modelo_coluna where nm_modelo = prm_modelo and nm_coluna = prm_nome;

        if ws_count <> 0 then

			update 	modelo_coluna
			set
					nm_coluna   = prm_nome,
					nm_destino  = prm_destino,
					tp_coluna   = prm_tipo,
					trfs_coluna = fun.converte(prm_trfs),
					replacein   = prm_replacein,
					replaceout  = prm_replaceout,
					mascara     = prm_mascara,
					nr_coluna   = prm_numero
			where 	nm_coluna 	= prm_nome
			and   	nm_modelo 	= prm_modelo;

            ws_count := SQL%ROWCOUNT;

            if ws_count <> 0 then
                commit;
            else
                raise ws_fail;
            end if;

        else

            select nvl2(max(id_coluna), max(id_coluna), 0)+1 into ws_key from modelo_coluna;

			loop

				ws_inc := ws_inc+1;

				select count(*) into ws_count from modelo_coluna where id_coluna = ws_key;

				if ws_count > 0 then
					select ws_key+ws_inc into ws_key from dual;
				else
					exit;
				end if;

			end loop;

			insert into modelo_coluna
				(id_coluna, nm_modelo, nr_coluna, nm_coluna, nm_destino, tp_coluna, trfs_coluna, replacein, replaceout, mascara)
			values
				(ws_key, upper(prm_modelo), nvl(prm_numero, (select max(nr_coluna)+1 from modelo_coluna where nm_modelo = upper(prm_modelo))), upper(prm_nome), upper(prm_destino), prm_tipo, upper(fun.converte(prm_trfs)), prm_replacein, prm_replaceout, prm_mascara);

			ws_count := SQL%ROWCOUNT;
			
			if ws_count <> 0 then
				commit;
			else
				raise ws_fail;
			end if;
		
		end if;
       
   end if;

exception
    when ws_fail then
        rollback;
        htp.p('FAIL');
    when others then
        htp.p('FAIL');
end import_change;

procedure importDelete ( prm_modelo varchar2 default null ) as

	ws_count number;

begin

	delete from modelo_cabecalho where upper(trim(nm_modelo)) = upper(trim(prm_modelo));
           
    ws_count := SQL%ROWCOUNT;
           
    if ws_count <> 0 then
        delete from modelo_coluna where upper(trim(nm_modelo)) = upper(trim(prm_modelo));
		commit;
    end if;
	htp.p('ok');
exception when others then
	htp.p('fail '||sqlerrm);
end importDelete;

procedure executenow ( prm_comando  varchar2 default null ) as

    job_id          number;
    ws_owner        varchar2(90);
    ws_name         varchar2(90);
    ws_line         number;
    ws_caller       varchar2(90);

begin
   
owa_util.who_called_me(ws_owner, ws_name, ws_line, ws_caller);

        dbms_job.submit(job => job_id,what => trim(prm_comando)||';',next_date => sysdate+((1/1440)/60), interval => null);
        commit;

end executenow;

end IMP;
/
show error