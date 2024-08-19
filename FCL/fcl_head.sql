set define off;
create or replace package FCL  is

FUNCTION ENCRYPT (P_TEXT  IN  VARCHAR2) RETURN RAW ; 

FUNCTION DECRYPT (P_RAW  IN  RAW) RETURN VARCHAR2 ;

	procedure iniciar (prm_screen varchar2 default null );
	procedure inputp(	prm_tipo	char default null,
			prm_ind		    char default null,
			prm_default	    char default null,
			prm_objeto	    char default null,
			prm_sufixo      char default null,
			prm_tmp_field   char default null,
			prm_script	    char default null,
			prm_list	    char default null,
            prm_ordem       varchar2 default null );

PROCEDURE LISTBOX (	PRM_CAMPO	    VARCHAR2 DEFAULT NULL,
					PRM_TMP_FIELD	VARCHAR2 DEFAULT NULL,
					PRM_SCRIPT	    VARCHAR2 DEFAULT NULL,
					PRM_DEFAULT	    VARCHAR2 DEFAULT NULL,
					PRM_LIST	    VARCHAR2 DEFAULT NULL,
					PRM_ATRIB       VARCHAR2 DEFAULT NULL,
					PRM_OBJ         VARCHAR2 DEFAULT NULL ) ;

	procedure save_points (	prm_objeto 		IN owa_util.ident_arr,
				prm_posx		IN owa_util.ident_arr,
				prm_posy		IN owa_util.ident_arr,
				prm_screen		char default 'DEFAULT');

	procedure savepa ( p_vl_salvo varchar2 default null,
				   p_cd_micro_visao	varchar2 default null,
				   p_parametros		varchar2 default null,
				   p_cd_ponto		varchar2 default null,
				   p_nm_ponto		varchar2 default null,
				   p_sub_ponto		varchar2 default null,
				   p_ar_diario		varchar2 default null,
				   p_ar_mensal		varchar2 default null,
				   p_ar_anual		varchar2 default null,
				   p_filtros		varchar2 default null,
				   p_cd_visao		varchar2 default null,
				   p_tp_renovacao	varchar2 default null,
				   p_ds_ponto		varchar2 default null,
				   p_tipo		varchar2 default null,
				   p_funcao		varchar2 default null,
				   fakeoption		varchar2 default null,
				   pcs_parametros	varchar2 default '1|1',
				   pcs_coluna	 	varchar2 default null,
				   pcs_agrupador	varchar2 default null,
				   pcs_rp		varchar2 default 'ROLL',
				   pcs_colup	 	varchar2 default null );

	procedure savevp (	p_funcao		varchar2 default null,
				p_cd_padrao		varchar2 default null,
				p_nm_padrao		varchar2 default null,
				p_tp_padrao		varchar2 default null,
				p_cd_ligacao		varchar2 default null,
                p_status varchar2 default null,
                p_ordem number default 1 );

	/*procedure dl_togo (	value1	varchar2 default null,
				value2	varchar2 default null );*/

	procedure dl_call (	p_cd_objeto	varchar2 default null,
				p_cd_objeto_go	varchar2 default null );

	procedure rurl ( 	prm_parametros		varchar2 default null,
				prm_micro_visao		varchar2 default null,
				prm_coluna		varchar2 default null,
				prm_agrupador		varchar2 default null,
				prm_rp			varchar2 default 'ROLL',
				prm_colup		varchar2 default null,
				prm_comando		varchar2 default null,
				prm_objid		varchar2 default null,
				prm_ccount		varchar2 default '0' );

	procedure savegd ( p_cd_micro_visao varchar2 default null,
					   p_funcao varchar2 default null,
					   p_cd_objeto		varchar2 default null,
					   p_nm_objeto		varchar2 default null,
					   p_sub_objeto		varchar2 default null,
					   p_atributos		varchar2 default null,
					   fakeoption		varchar2 default null,
					   p_tp_objeto		varchar2 default null,
					   p_ds_objeto		varchar2 default null,
					   p_cs_colup       varchar2 default null );

	procedure savecallist ( p_funcao varchar2 default null,
		                    p_cd_objeto varchar2 default null,
		                    fakeoption varchar2 default null,
		                    p_nm_objeto varchar2 default null,
		                    p_ds_objeto varchar2 default null );

	procedure savecd ( 	p_funcao		varchar2 default null,
						p_nds_tabela		varchar2 default null,
						p_nds_owner		varchar2 default null,
						p_nds_tfisica	varchar2 default null,
						p_nds_cd_empresa	varchar2 default null,
						p_nds_cd_codigo	varchar2 default null,
						p_nds_cd_descricao	varchar2 default null );

	procedure update_sinal ( prm_sinal varchar2 default null,
                             prm_tipo  varchar2 default null,
						     prm_valor varchar2 default null );

	procedure savesign (	p_funcao		varchar2 default null,
		   		p_cd_sinal		varchar2 default null,
		   		p_ds_sinal		varchar2 default null,
		   		p_tp_sinal		varchar2 default null,
		   		p_fx_01			varchar2 default null,
		   		p_fx_02			varchar2 default null,
		   		p_fx_03			varchar2 default null,
		   		p_fx_04			varchar2 default null,
		   		p_fx_05			varchar2 default null );

	procedure ed_gadg ( ws_par_sumary varchar2, prm_tipo varchar2 default null );

	procedure ed_call ( prm_object varchar2,
                        prm_screen varchar2 default null );

	/*procedure edit_ufiltro( prm_micro_visao 	varchar2 default null,
				            prm_cd_coluna		varchar2 default null );*/

	procedure edit_ofiltro( p_item	        char default '1',
							new_cd_objeto	varchar2 default null,
						    new_cd_coluna	varchar2 default null,
							new_condicao	varchar2 default null,
							new_conteudo	varchar2 default null,
							prm_ligacao	    varchar2 default 'and',
							prm_visao	    varchar2 default null,
							prm_agrupado    char default 'N',
							prm_usuario     varchar2 default null );

	procedure save_par ( y IN owa_util.ident_arr,
				         x IN owa_util.ident_arr,
				         ws_type varchar2 default 'NOSUB');

	procedure save_float (	prm_conteudo varchar2 default null,
						    prm_padrao   varchar2 default null,
						    prm_screen   varchar2 default null );

	procedure save_float_filter ( prm_conteudo varchar2 default null,
						          prm_coluna varchar2 default null,
						          prm_screen varchar2 default null );

	procedure savego ( prm_objeto varchar2 default null,
		               prm_go     varchar2 default null,
					   prm_ordem  varchar2 default null );

	procedure savecall ( prm_objeto		varchar2 default null,
		                 prm_objeto_go  varchar2 default null,
					     prm_screen     varchar2 default null);

	procedure ajscreen ( 	prm_screen		char default null );

	procedure ajobjeto ( 	prm_objeto		char default null );

	procedure dl_ofiltro ( prm_key number default null );

	procedure dl_vp (	ws_par_sumary		char default null );

	procedure dl_cd (	ws_par_sumary		char default null );

	procedure dl_sn (	ws_par_sumary		char default null );

	procedure dl_obj ( prm_cod  char     default null,     
					   prm_tela char     default null, 
					   prm_list varchar2 default null );

	procedure get_par  (  	ws_par_sumary		varchar2 default null,
				ws_type			varchar2 default 'NOSUB' );

	procedure get_float  ( prm_screen varchar2 default null );

	procedure get_float_filter  ( prm_screen varchar2 default null );

	procedure save_pwd ( prm_senha varchar2 default null,
		                 --prm_senha2 varchar2 default null,
                         prm_email varchar2 default null,
					     prm_number varchar2 default null,
					     prm_user  varchar2 default null,
					     prm_nome varchar2 default null );

	procedure ch_pwd;

	procedure ENTRY (	prm_campo	    varchar2 default null,
						prm_tmp_field	varchar2 default null,
						prm_script	    varchar2 default null,
						prm_default	    varchar2 default null,
						prm_list	    varchar2 default null,
						prm_tipo	    varchar2 default 'TEXT',
						prm_objeto      varchar2 default null,
						prm_atrib       varchar2 default null  );

	procedure savecalc (	p_cd_coluna		varchar2 default null,
				p_cd_grupo		varchar2 default null,
				p_nm_rotulo		varchar2 default null,
				p_coluna		varchar2 default null,
				p_objeto		varchar2 default null,
				p_operacao		varchar2 default null,
				p_st_formula		varchar2 default null,
				p_funcao		varchar2 default null,
				p_st_agrupador		varchar2 default null,
				p_mvisao		varchar2 default null );

	procedure savemv ( 	p_funcao		varchar2 default null,
			   	p_nm_micro_visao	varchar2 default null,
			   	p_nm_tabela		varchar2 default null,
			   	p_ds_micro_visao	varchar2 default null,
			   	p_cd_grupo_funcao	varchar2 default null );

	procedure float_menu ( prm_screen varchar2 default null );
	
	procedure closer_menu;

	procedure call_list(	prm_call	 	varchar2 default null,
				prm_posicao		varchar2 default null,
				prm_screen varchar2 default null );

	procedure update_call( prm_item varchar2 default null,
					   prm_list varchar2 default null,
					   prm_objeto varchar2 default null,
					   prm_screen varchar2 default null,
					   prm_acao integer default 1);

	procedure list_sinal;

	procedure save_sinal ( par_name varchar2 default 'Novo',
					   par_nameds varchar2 default null,
					   par_sinais number default 1 );

	procedure delete_csinal( d_usuario varchar2 default null,
						     d_pa      varchar2 default null,
						     d_coluna  varchar2 default null,
						     d_sinal   varchar2 default null );

	procedure insert_csinal( i_usuario varchar2 default null,
						     i_pa      varchar2 default null,
						     i_coluna  varchar2 default null,
						     i_sinal   varchar2 default null );

	procedure kill ( prm_sid varchar2 default null, prm_serial varchar2 default null );

	procedure list_vpadrao ( prm_order varchar2 default '1',
                             prm_dir   varchar2 default '1' );

	procedure alter_padrao ( prm_padrao varchar2 default null,
                             prm_campo varchar2 default null,
						     prm_valor varchar2 default null );


	procedure add_padrao( prm_padrao varchar2 default null,
                          prm_nome varchar2 default null,
					      prm_tipo varchar2 default null,
					      prm_ligacao varchar2 default null,
					      prm_status varchar2 default null,
                          prm_ordem number default 1,
						  prm_float   varchar2 default null );


	procedure dl_gadg ( prm_objeto varchar2 default null );

	procedure nulopass;

	procedure list_cdesc ( prm_order varchar2 default '1',
                           prm_dir varchar2 default '1' );

	procedure list_ofiltro ( ws_par_sumary varchar2 default null,
                             prm_visao varchar2 default null,
						     prm_order varchar2 default '1',
						     prm_dir varchar2 default '1' );

	procedure list_sfiltro( ws_par_sumary varchar2 default null );

	procedure edit_sfiltro ( p_item          char default '1',
			                 new_cd_objeto   varchar2 default null,
			                 new_micro_visao varchar2 default null,
			                 new_cd_coluna   varchar2 default null,
			                 new_condicao	 varchar2 default null,
			                 new_conteudo	 varchar2 default null,
			                 new_ligacao	 varchar2 default 'and' );

	/*procedure dl_sfiltro ( p_item        char default '1',
						   p_cd_objeto	 varchar2 default null,
						   p_micro_visao varchar2 default null,
						   p_cd_coluna	 varchar2 default null,
						   p_condicao	 varchar2 default null,
						   p_conteudo	 varchar2 default null,
						   p_ligacao	 varchar2 default 'and',
						   p_screen	     varchar2 default null );*/

	procedure lista_sfiltro( prm_visao varchar2 default null );

	procedure list_go ( prm_objeto varchar2 default null,
						prm_order varchar2 default '1',
						prm_dir varchar2 default '1' );

	procedure listgo_objetos ( prm_objeto varchar2 default null,
                               prm_visao  varchar2 default null,
							   prm_campo  varchar2 default null);

	procedure list_call_end( prm_objeto varchar2 default null,
					         prm_screen varchar2 default null );

	procedure list_call  ( prm_objeto varchar2 default null,
						   prm_screen varchar2 default null );

	procedure EDIT_VPADRAO ( ws_par_sumary 	varchar2 default null );


	procedure EDIT_SINAL   ( ws_par_sumary 	varchar2 default null );

	/*procedure NEW_CALC (	prm_mvisao 	varchar2 default null,
			     	        prm_coluna	varchar2 default null );*/

	procedure load_tipos;

	procedure save_obj( prm_nome varchar2 default null,
					    prm_atributo varchar2 default null,
					    prm_grupo varchar2 default null,
					    prm_tipo varchar2 default null,
                        prm_visao varchar2 default null );

	procedure LOAD_TABLES ( prm_order varchar2 default '1',
                            prm_dir varchar2 default '1' );

	procedure new_view ( prm_nome varchar2 default null,
                         prm_tabela varchar2 default null,
					     prm_desc varchar2 default null,
					     prm_grupo varchar2 default null );

	procedure save_view ( prm_view varchar2 default null,
                          prm_valor varchar2 default null,
                          prm_tipo varchar2 default null );


	/*procedure LOAD_OCOLUNAS( PRM_OWNER	varchar2 default null,
				 PRM_TABELA	varchar2 default null );*/

	procedure show_screen ( prm_screen	varchar2 default null,
			                prm_clear	varchar2 default 'N',
			                prm_screen_ant	varchar2 default null,
                            prm_refresh varchar2 default 'N',
			                prm_parametro varchar2 default null,
			                prm_tipo varchar2 default null,
							prm_token varchar2 default null );

	procedure load_external( prm_screen varchar2 default null );

	procedure clear_screen ( prm_screen	char default 'DEFAULT',
				 prm_nscreen    char default null,
				 prm_visao      char default 'N' );

	procedure screen_prop  ( ws_par_sumary 	varchar2 );

	procedure list_objetos (  prm_tipo      varchar2 default 'CONSULTA',
							  prm_screen    varchar2 default null,
							  prm_order     varchar2 default '1',
							  prm_dir       varchar2 default '1',
							  prm_visao     varchar2 default null );

	procedure list_crocks;

	procedure listlig (	prm_campo	char default null,
			prm_tmp_field	char default null,
			prm_script	char default null,
			prm_default	char default null,
			prm_list	char default null,
            prm_ordem   varchar2 default null );

	procedure load_crocks ( prm_visao    varchar2 default null,
							prm_valores  varchar2 default null,
							prm_busca    varchar2 default null,
							prm_completo varchar2 default 'S',
							prm_ordem    varchar2 default '1',
							prm_dir      varchar2 default '1' );

	procedure exclude_column ( prm_coluna varchar2 default null,
                               prm_visao varchar2 default null );

	procedure monta_article ( prm_id      varchar2 default null,
                              prm_section varchar2 default null, 
						      prm_count   number   default 1    );

	procedure inserir_objeto ( prm_objeto varchar2 default null, 
	                           prm_screen varchar2 default 'DEFAULT', 
							   prm_screen_ant varchar2 default 'DEFAULT' );


    procedure call_insert ( prm_objeto varchar2 default null,
                        prm_screen varchar2 default null); 

	procedure save_prop ( prm_prop        varchar2 default null,
			              prm_valor       varchar2 default null,
			              prm_objeto	  varchar2 default null,
			              prm_url_default varchar2 default null,
			              prm_screen	  varchar2 default 'DEFAULT');
	

	procedure save_formula( prm_coluna   varchar2 default null,
							prm_formula  varchar2 default null,
							prm_tabela   varchar2 default null );

	procedure save_mvisao (	p_cd_coluna		 IN owa_util.ident_arr,
							p_gravacao		 IN owa_util.ident_arr,
							p_nm_rotulo		 IN owa_util.ident_arr,
							p_st_gerar		 IN owa_util.ident_arr,
							p_st_agrupador	 IN owa_util.ident_arr,
							p_nm_mascara	 IN owa_util.ident_arr,
							p_cd_ligacao	 IN owa_util.ident_arr,
							p_st_com_codigo	 IN owa_util.ident_arr,
							p_st_alinhamento IN owa_util.ident_arr,
							p_st_resumido	 IN owa_util.ident_arr,
							p_st_negrito	 IN owa_util.ident_arr,
							p_st_invisivel	 IN owa_util.ident_arr,
							p_nm_unidade	 IN owa_util.ident_arr,
							p_tabela		 IN VARCHAR2 DEFAULT NULL );

	procedure savescr ( p_screen		varchar2 default null,
						p_descricao		varchar2 default null,
						p_publico		varchar2 default null,
						p_ds_screen		varchar2 default null,
						p_funcao		varchar2 default null,
						p_grupof		varchar2 default null,
						p_cor_fundo		varchar2 default null,
						p_url_fundo		varchar2 default null,
						p_or_grupo		varchar2 default null,
						p_or_item		varchar2 default 0,
						p_dispositivo   varchar2 default null,
						act_screen		varchar2 default null,
						p_timer         number,
						p_flex          varchar2 default null);

	procedure av_prop ( ws_par_sumary varchar2,
				        ws_type       varchar2 default 'NOSUB',
						prm_screen    varchar2 default 'DEFAULT' );

	procedure ponto_av ( prm_micro_visao varchar2 default null,
						 ws_par_sumary	 varchar2 default null,
						 ws_par_tipo	 varchar2 default null,
						 ws_par_seecol	 varchar2 default null,
						 prm_zindex      varchar2 default null,
						 ws_par_linhas	 varchar2 default null,
						 ws_par_colunas	 varchar2 default null );

	procedure LOAD_MVIEW ( PRM_CD_GRUPO char default null,
			               PRM_MVISAO   char default null );

	procedure LOAD_COLUMNS ( PRM_MICRO_VISAO char default null );

	procedure dl_column ( prm_view   varchar2 default null,
                          prm_coluna varchar2 default null );

	procedure INITCAB (	ws_xcount	in out 	number,
						ws_scol		in out 	number,
						prm_coluna	in out 	varchar2,
						ws_mode		in out 	varchar2,
						cd_ligacao	in out 	varchar2,
						st_com_codigo   in out  varchar2,
						ws_content_ant	in out 	long,
						prm_micro_visao	varchar2 default null,
						prm_objid       varchar2 default null,
						prm_invisible   in out 	number );

	procedure pickfont ( prm_campo	    varchar2 default null,
				         prm_tmp_field	varchar2 default null,
				         prm_script	    varchar2 default null,
				         prm_default	varchar2 default null,
				         prm_attrib     varchar2 default null,
				         prm_obj        varchar2 default null );

	procedure PICKFONTSIZE ( prm_campo	    char default null,
							 prm_tmp_field	char default null,
							 prm_script	    char default null,
							 prm_default	char default null );

	procedure ARRGETPROP (	prm_objeto	char default null,
							prm_cd_prop	in out DBMS_SQL.VARCHAR2_TABLE,
							prm_prop	in out DBMS_SQL.VARCHAR2_TABLE,
							prm_rotulo	in out DBMS_SQL.VARCHAR2_TABLE,
							prm_tipo	in out DBMS_SQL.VARCHAR2_TABLE,
							prm_sufixo	in out DBMS_SQL.VARCHAR2_TABLE,
							prm_script	in out DBMS_SQL.VARCHAR2_TABLE,
							prm_list	in out DBMS_SQL.VARCHAR2_TABLE,
							prm_grupo	in out DBMS_SQL.VARCHAR2_TABLE,
							prm_hint	in out DBMS_SQL.VARCHAR2_TABLE,
							prm_ordem	in out DBMS_SQL.NUMBER_TABLE,
							prm_screen  varchar2 default 'DEFAULT' );

	procedure keywords;

	procedure CHECKBOX (    prm_chkname	    varchar2 default null,
							prm_campo	    varchar2 default null,
							prm_prop	    varchar2 default null,
							prm_chk		    varchar2 default null,
							prm_nchk	    varchar2 default null,
							prm_default	    varchar2 default null,
							prm_tmp_field	varchar2 default null,
							prm_attrib      varchar2 default null,
							prm_objeto      varchar2 default null );

	procedure pickcolor (  prm_valor       varchar2 default null,
	                       prm_placeholder varchar2 default null,
						   prm_id          varchar2 default null,
						   prm_attrib      varchar2 default null,
						   prm_obj         varchar2 default null );

	procedure NOPEN( 	prm_nome	char	default null );

	procedure NCLOSE( 	prm_nome	char	default null );

	procedure DATA(		prm_objeto	    varchar	 default null,
				        prm_parametros  varchar2 default null,
				        prm_screen      varchar2 default null );

	/* clonado do fun para sincroniza&ccedil;&atilde;o */
	
	PROCEDURE CHAROUT ( PRM_PARAMETROS    VARCHAR2 DEFAULT NULL,
					    PRM_MICRO_VISAO   VARCHAR2 DEFAULT NULL,
					    PRM_OBJETO        VARCHAR2 DEFAULT NULL,
					    PRM_SCREEN        VARCHAR2 DEFAULT NULL ) ;
					   
				
	procedure VALOR_PONTO ( prm_parametros   varchar2 default null,
						    prm_micro_visao	 varchar2 default null,
						    prm_objeto		 varchar2 default null, 
						    prm_screen       varchar2 default null,
						    prm_formula      varchar2 default null,
							prm_mascara      varchar2 default null );
							
	procedure um ( prm_coluna  varchar2 default '$[no_co]',
                   prm_visao   varchar2 default '$[no_ob]',
                   prm_content varchar2 default null );
	
						
	/* fim dos clones */

	procedure SETPOS( prm_locais	char	default null );

	procedure NEGADO(	J_objeto	char	default null );


	procedure BASET(	j_base		char	default null );

	function HTEXTO(	j_texto		char	default null,
				j_size		char	default null,
				j_cor		char	default null,
				j_href		char	default null,
				cattributes	char	default null ) return varchar2;

	procedure POSICIONA_OBJETO	( prm_objeto	char	default null,
					  prm_usuario   char    default null,
					  prm_screen	char	default null,
					  prm_browser   char    default 'DEFAULT' );

	procedure SALVA_POSICAO	( prm_objeto varchar2 default null,
			              prm_screen varchar2 default null,
				          prm_posx   varchar2 default '0',
				          prm_posy   varchar2 default '0',
				          prm_zindex varchar2 default null,
						  prm_tipo varchar2 default 'posicao' );

	procedure XDATALINK ( 	prm_gif		varchar2 default null,
				prm_link	varchar2 default null,
				prm_type	varchar2 default 'GIF',
				prm_alt		varchar2 default null,
				prm_positions	varchar2 default null,
				prm_url		varchar2 default null,
				prm_comando     varchar2 default null );

	function FDATALINK(	prm_gif       	varchar2 default null,
				prm_link      	varchar2 default null,
				prm_type	varchar2 default 'GIF',
				prm_alt		varchar2 default null,
				prm_panel	varchar2 default 'COLUNA',
				prm_form	varchar2 default null,
				prm_select	varchar2 default null,
				prm_url		varchar2 default null,
				prm_comando     varchar2 default null ) return varchar2;

	/*function BOTAO(		j_nome		char	default null,
				j_evento	char	default null,
				j_variavel	char	default null) return varchar2;*/

	function FPDATA (	prm_mode	varchar2 default null,
				prm_check	varchar2 default null,
				prm_data	varchar2 default null,
				prm_other	varchar2 default null ) return varchar2;

	procedure PDATA (	prm_mode	varchar2 default null,
				prm_check	varchar2 default null,
				prm_data	varchar2 default null,
				prm_other	varchar2 default null );

	procedure DATALINK(	prm_gif       	varchar2 default null,
				prm_link      	varchar2 default null,
				prm_type	varchar2 default 'GIF',
				prm_alt		varchar2 default null,
				prm_panel	varchar2 default 'COLUNA',
				prm_form	varchar2 default null,
				prm_select	varchar2 default null,
				prm_url		varchar2 default null,
				prm_comando     varchar2 default null,
				prm_id		varchar2 default null,
				prm_idgif	varchar2 default null,
				prm_addscript	varchar2 default null,
				prm_attrib	varchar2 default 'title',
				prm_cattributes varchar2 default null,
				prm_hideb	varchar2 default null );

	procedure FORMSELECTOPTION(
				ctext       in varchar2,
				cvalue	    in varchar2,
				cattributes in varchar2 DEFAULT NULL,
				cselected   in varchar2 DEFAULT NULL );


	procedure TABLEDATAOPEN(calign	    in varchar2 DEFAULT NULL,
				ccolspan    in varchar2 DEFAULT NULL,
				cattributes in varchar2 DEFAULT NULL,
				crowspan    in varchar2 DEFAULT NULL );

	procedure TABLEDATACLOSE;

	procedure dump_screen;

	procedure list_users ( prm_order varchar2 default '1',
                           prm_dir varchar2 default '1' );

	procedure advancedUsers ( prm_user varchar2 );

	procedure alter_user ( prm_nome varchar2 default null,
                           prm_valor varchar2 default null,
					       prm_tipo varchar2 default null );

	procedure delete_user( usu_nome_d varchar2 default null );


	procedure save_user ( prm_nome      varchar2 default null,
						  prm_completo  varchar2 default null,
						  prm_status    varchar2 default null,
						  prm_email     varchar2 default null,
						  prm_senha     varchar2 default null,
						  prm_permissao varchar2 default 'none',
						  prm_grupo     varchar2 default null );


	procedure screen_access ( prm_usuario     varchar2 default null, 
							  prm_conteudo    varchar2 default 'FULL',
							  prm_grupo       varchar2 default null );

	procedure screen_change ( prm_usuario varchar2 default null,
                          prm_tela    varchar2 default null,
						  prm_tipo    varchar2 default 'time',
						  prm_valor   number default null );

	procedure list_screen ( prm_grupo varchar2 default 'all', 
		                    prm_usuario varchar2 default null );

	procedure add_screen_access ( prm_usuario varchar2 default null,
					              prm_tela    varchar2 default null,
					              prm_tempo   number default 0,
					              prm_ordem   number default 0 );

    procedure delete_screen_access ( prm_usuario varchar2 default null,
					                 prm_tela    varchar2 default null );

	procedure object_access ( prm_usuario  varchar2 default null, 
                              prm_conteudo varchar2 default 'FULL');
	
	procedure object_access_list ( prm_visao   varchar2 default null,
                                   prm_usuario varchar2 default null ) ;

	PROCEDURE ADD_OBJECT_ACCESS ( PRM_USUARIO VARCHAR2 DEFAULT NULL,
					              PRM_OBJ     VARCHAR2 DEFAULT NULL ) ;

	procedure td_access ( prm_usuario  varchar2 default null,
	                      prm_conteudo varchar2 default 'FULL' );

	procedure add_td_access( prm_usuario varchar2 default null,
	                         prm_regra varchar2 default null,
	                         prm_tipo varchar2 default null,
	                         prm_address varchar2 default null,
	                         prm_hi number default 8,
	                         prm_hf number default 18,
	                         prm_semana varchar2 default 'dia util' );

	procedure dl_td_access ( prm_usuario varchar2 default null,
                             prm_nome varchar2 default null	);

    procedure delete_object_access ( prm_usuario varchar2 default null,
					                 prm_obj     varchar2 default null );

    procedure column_access ( prm_usuario  varchar2 default null, 
                              prm_conteudo varchar2 default 'FULL' );

    procedure add_column_access ( prm_usuario varchar2 default null,
				       			  prm_coluna  varchar2 default null,
							      prm_visao   varchar2 default null );

	procedure delete_column_access ( prm_nome   varchar2 default null,
			                         prm_coluna varchar2 default null,
			                         prm_visao  varchar2 default null );

	procedure list_column_access ( prm_visao    varchar2 default null, 
	                               prm_usuario  varchar2 default null );

	procedure xlogout ( prm_sessao varchar2 default null );

    procedure GPS( prm_posicao	varchar	default null );

	procedure saveview( prm_view varchar2 default null,
	                    prm_nome varchar2 default null,
		                prm_desc varchar2 default null,
						prm_grupo varchar2 default null ,
                        prm_tipo varchar2 default 'u' );

    procedure alterorder ( prm_objeto varchar2 default null,
    					   prm_valor  varchar2 default null );

    procedure savecolumn ( p_cd_coluna varchar2 default null,
		     	           p_visao varchar2 default null,
					       prm_template varchar2 default 'N' );

    procedure filtro_geral;

    procedure getcolumn( prm_visao varchar2 default null );

    procedure getfiltro( prm_usuario varchar2 default null,
                         prm_order varchar2 default '1',
					     prm_dir varchar2 default '1' );

    procedure setfiltro( prm_usuario varchar2 default null,
						prm_visao varchar2 default null,
						prm_coluna varchar2 default null,
						prm_condicao varchar2 default null,
						prm_conteudo varchar2 default null,
						prm_ligacao varchar2 default 'and' );
    
    procedure setdestaque( prm_usuario    varchar2 default null,
						   prm_objeto     varchar2 default null,
						   prm_coluna     varchar2 default null,
						   prm_condicao   varchar2 default null,
						   prm_conteudo   varchar2 default null,
						   prm_fundo      varchar2 default null, 
						   prm_fonte      varchar2 default null, 
						   prm_tipo       varchar2 default null,
						   prm_prioridade varchar2 default null );

	procedure deletefiltro( prm_key number default null );

	procedure preferencias( prm_usuario varchar2 default null);

	procedure a_preferencias( prm_usuario varchar2 default null,
							  prm_propriedade varchar2 default null,
						  	  prm_acao varchar2 default null );

	procedure blink ( prm_objeto varchar2 default null,
                      prm_visao varchar2 default null,
				      prm_order varchar2 default '1',
				      prm_dir varchar2 default '1' );

	procedure blink_coluna;

	procedure alter_agrupadores ( prm_objeto varchar2 default null,
                                  prm_agrupadores varchar2 default null,
                                  prm_tipo varchar2 default null );

	/*procedure inserir_blink( prm_usuario varchar2 default null,
						 prm_pa varchar2 default null,
						 prm_coluna varchar2 default null,
						 prm_condicao varchar2 default null,
						 prm_conteudo varchar2 default null,
						 prm_fundo varchar2 default null,
						 prm_fonte varchar2 default null,
                         prm_tipo varchar2 default null,
						 prm_where varchar2 default 'geral',
						 prm_prioridade number default 0 );*/

	procedure edit_blink ( prm_key      number   default null,
						   prm_valor    varchar2 default null,
						   prm_alter    varchar2 default null );

	procedure delete_blink( prm_key      number   default null );

	procedure list_blink ( l_pa varchar2 default null );

	procedure list_mblink ( prm_objeto varchar2 default null,
                            prm_usuario varchar2 default 'N/A',
						    prm_order varchar2 default '1',
						    prm_dir varchar2 default '1' );

    procedure load_dado ( prm_nome varchar2 default null,
                          prm_tipo varchar2 default null,
                          prm_time number );

	procedure edit_view;

	procedure new_query ( prm_obj varchar2 default null );

	PROCEDURE REG_ONLINE  ( prm_tipo      varchar2 default null,
                            prm_evento    varchar2 default null,
                            prm_status    varchar2 default null,
                            prm_usuario   varchar2 default null,
                            prm_qtde      varchar2 default null );

	procedure STATUS_PROCESS ( prm_cd_processo varchar2,
                              prm_ds_processo varchar2,
                              prm_comando varchar2);

	procedure mask ( prm_order varchar2 default '1',
                     prm_dir varchar2 default '1' );

	procedure edit_mask ( prm_mask varchar2 default null,
                          prm_valor varchar2 default null );

	procedure dl_mask ( prm_mask varchar2 default null );

	procedure load_mask ( prm_mask varchar2 default null,
					      prm_desc varchar2 default null );

	/*procedure gotoobjeto ( prm_objeto varchar2 default null,
                           prm_order varchar2 default '1',
					       prm_dir varchar2 default '1' );*/


	procedure load_goto ( prm_grafico varchar2 default null,
					      prm_drill varchar2 default null);

	procedure dl_goto ( prm_objeto varchar2 default null,
                        prm_drill   varchar2 default null );

	procedure save_column ( prm_visao varchar2 default null,
                          prm_name varchar2 default null,
                          prm_campo varchar2 default null,
                          prm_valor varchar2 default null );
						  
	procedure testa_formula ( prm_tabela  varchar2 default null,
							  prm_coluna  varchar2 default null,
							  prm_screen  varchar2 default null );

	procedure load_column ( prm_visao varchar2 default null,
                          prm_name varchar2 default null );

	procedure auto_complete ( prm_visao varchar2 default null,
                          prm_letters varchar2 default null );

    procedure load_drill ( prm_objeto varchar2 default null,
                           prm_parametros varchar2 default null,
                           prm_track   varchar2 default null,
                           prm_objeton varchar2 default null );

	procedure ex_obj( prm_objeto varchar2 default null );

	procedure list_vconteudo ( prm_usuario varchar2 default null, 
							   prm_todo varchar2 default 'S' );

	procedure edit_vconteudo( prm_variavel varchar2 default null,
                              prm_conteudo varchar2 default null,
							  prm_usuario  varchar2 default null );

	procedure add_vconteudo ( prm_variavel varchar2 default null,
	                          prm_usuario  varchar2 default 'DWU',
                              prm_lock     varchar2 default 'N' ) ;

	procedure dl_vconteudo ( prm_variavel varchar2 default null,
                             prm_usuario  varchar2 default null );

	procedure alter_value( prm_object varchar2 default 'DEFAULT',
                           prm_prop varchar2 default null,
                           prm_valor1 varchar2 default null,
					       prm_valor2 varchar2 default null,
					       prm_screen varchar2 default 'DEFAULT' );

	procedure list_calculada ( prm_objeto varchar2 default null,
                               prm_visao varchar2 default null );

	procedure create_linha( prm_objeto varchar2 default null,
                        prm_visao varchar2 default null,
                        prm_coluna varchar2 default null,
                        prm_show varchar2 default null,
						prm_desc varchar2 default null,
						prm_formula varchar2 default null );

	procedure dl_linha ( prm_objeto varchar2 default null,
                     prm_visao varchar2 default null,
					 prm_coluna varchar2 default null,
					 prm_show varchar2 default null );

	procedure dre;

	procedure dre_expand ( prm_mapa varchar2 default null );

	procedure dre_padrao ( prm_map varchar2 default null );

	procedure dre_lines ( prm_map varchar2 default null,
                     prm_padrao varchar2 default null );

	procedure dre_line ( prm_map varchar2 default null,
                     prm_padrao varchar2 default null,
                     prm_item varchar2 default null );

	procedure dre_filtro ( prm_map varchar2 default null,
                     prm_padrao varchar2 default null );

	procedure new_dre ( prm_mapa varchar2 default null,
                    prm_dsmapa varchar2 default null,
					prm_ligacao varchar2 default null,
					prm_dsmasc varchar2 default null,
					prm_point varchar2 default null,
					prm_right varchar2 default null,
					prm_masc_coluna varchar2 default null,
					prm_coluna_deff varchar2 default null );

	procedure save_dre ( prm_mapa varchar2 default null,
                    prm_dsmapa varchar2 default null,
					prm_dsmasc varchar2 default null,
					prm_point varchar2 default null,
					prm_right varchar2 default null,
					prm_masc_coluna varchar2 default null );

	procedure dl_dre ( prm_mapa varchar2 default null );

	procedure new_padrao ( prm_mapa varchar2 default null,
                    prm_cdpadrao varchar2 default null,
					prm_dspadrao varchar2 default null,
					prm_visao varchar2 default null );

	procedure dl_padrao ( prm_padrao varchar2 default null );

	procedure new_defline ( prm_mapa varchar2 default null,
                    prm_item varchar2 default null,
					prm_padrao varchar2 default null,
					prm_coluna varchar2 default null,
                    prm_defline varchar2 default null );

	procedure defline_expand ( prm_item varchar2 default null,
                           prm_coluna varchar2 default null,
                           prm_padrao varchar2 default null,
                           prm_mapa varchar2 default null );

	procedure save_defline ( prm_mapa varchar2 default null,
					prm_padrao varchar2 default null,
					prm_coluna varchar2 default null,
					prm_item varchar2 default null,
					prm_indice varchar2 default null,
					prm_st_coluna varchar2 default null,
                    prm_sub_coluna varchar2 default null );

	procedure dl_defline ( prm_item varchar2 default null,
                       prm_coluna varchar2 default null,
                       prm_mapa varchar2 default null,
                       prm_padrao varchar2 default null );

	procedure new_filtro ( prm_mapa varchar2 default null,
                    prm_padrao varchar2 default null,
                    prm_item varchar2 default null,
                    prm_coluna varchar2 default null,
					prm_condicao varchar2 default null,
					prm_conteudo varchar2 default null );

	procedure dl_filtro ( prm_mapa varchar2 default null,
                      prm_padrao varchar2 default null,
                      prm_item varchar2 default null );

	procedure dl_object ( prm_object varchar2 default null );

	procedure refresh_Session;

	procedure fakelist ( prm_ident varchar2 default null,
	                     prm_titulo varchar2 default null,
	                     prm_campo varchar2 default null,
	                     prm_visao varchar2 default null,
						 prm_ref   varchar2 default null );
	
	procedure fakelistoptions ( prm_ident     varchar2 default null,
			                    prm_campo     varchar2 default null,
			                    prm_visao     varchar2 default null,
								prm_ref       varchar2 default null,
								prm_adicional varchar2 default null,
								prm_search    varchar2 default null );

	procedure alter_attrib ( prm_objeto  varchar2 default null,
	                         prm_prop    varchar2 default null,
	                         prm_value   varchar2 default null,
                             prm_usuario varchar2 default null );

	procedure grupos ( prm_order varchar2 default '1',
                       prm_dir varchar2 default '1' );

	procedure create_grupo( prm_grupo varchar2 default null,
                            prm_nome varchar2 default null );

	procedure edit_grupo( prm_grupo varchar2 default null,
                      prm_valor varchar2 default null,
					  prm_tipo varchar2 default null );

	procedure menu ( prm_menu varchar2 default null,
                     prm_default varchar2 default null );
	
	procedure menu_screen_access ( prm_usuario varchar2 default null );
	
	procedure menu_column_access ( prm_usuario varchar2 default null );
	
	procedure menu_object_access ( prm_usuario varchar2 default null );
	
	procedure menu_td_access ( prm_usuario varchar2 default null );

	procedure consulta ( prm_objeto      varchar2 default null,
						 prm_visao       varchar2 default null,
						 prm_nome        varchar2 default null,
						 prm_grupo       varchar2 default null,
						 prm_agrupamento varchar2 default null );

	procedure alter_consulta ( prm_nome        varchar2 default null,
							   prm_valor       varchar2 default null,
							   prm_tipo        varchar2 default null
						     );

	procedure save_consulta ( prm_visao varchar2 default null,
                              prm_nome varchar2 default null,
						      prm_desc varchar2 default null,
						      prm_coluna varchar2 default null,
						      prm_colup varchar2 default null,
						      prm_agrupador varchar2 default null,
                              prm_grupo varchar2 default null,
                              prm_rp varchar2 default null,
						      prm_filtros varchar2 default null );

	procedure remove_location ( prm_obj varchar2 default null,
                            prm_screen varchar2 default null );

	procedure gusuarios ( prm_order varchar2 default '1',
                          prm_dir   varchar2 default '1' );

	procedure create_gusuarios( prm_grupo varchar2 default null,
                                prm_nome varchar2 default null );

	procedure alter_gusuario ( prm_group varchar2 default null,
                               prm_usuario varchar2 default null);

	procedure text_post ( prm_objeto varchar2 default null,
				      prm_line varchar2 default null,
					  prm_group varchar2 default null );

	procedure insert_post ( prm_objeto varchar2 default null,
                        prm_screen varchar2 default null,
                        prm_visao varchar2 default null,
                        prm_usuario varchar2 default null,
                        prm_msg varchar2 default null,
                        prm_time number default 30,
                        prm_line varchar2 default null,
                        prm_email char default 'N',
                        prm_sms char default 'N',
                        prm_filtro varchar2 default null,
                        prm_show   varchar2 default 'Y',
                        prm_origem varchar2 default '$[NO_NAME]');

	procedure remove_post ( prm_id number default null );

	procedure check_text_post;

	procedure countCheckPost;

	procedure js_log ( prm_msg varchar2 default null,
                       prm_url varchar2 default null,
                       prm_line varchar2 default null,
                       prm_tipo varchar2 default 'ERRO' );

	procedure alter_ordem_geral ( prm_valor varchar2 default null,
                                  prm_objeto varchar2 default null );

	procedure alter_ordem_padrao ( prm_ordem varchar2 default null,
                                   prm_tipo varchar2 default null,
                                   prm_prop varchar2 default null );

	Procedure Exec_Script ( Prm_Objeto     Varchar2 Default Null,
                            prm_parametros varchar2 default null );

	procedure Programa_Execucao ( prm_objeto     varchar2 default null,
	                              prm_parametros varchar2 default null,
	                              prm_screen     varchar2 default null );

    /*Function encrypt (p_text  IN  VARCHAR2) RETURN RAW;

    Function Decrypt (P_Raw  In  Raw) Return Varchar2;*/

    procedure notify_me ( prm_notify varchar2 default null,
                          prm_ponto varchar2 default null,
                          prm_visao varchar2 default null );

	procedure save_notify ( prm_notify varchar2 default null,
                            prm_dsnotify varchar2 default null,
						    prm_ponto varchar2 default null,
						    prm_receiver varchar2 default null,
						    prm_texto varchar2 default null,
						    prm_visao varchar2 default null,
						    prm_update char default 'N' );

	procedure notify_list;

	procedure dl_notify ( prm_notify varchar2 default null );

	procedure alter_filtro_notify ( prm_item varchar2 default null,
                                    prm_notify varchar2 default null,
                                    prm_visao varchar2 default null,
							        prm_coluna varchar2 default null,
							        prm_condicao varchar2 default null,
							        prm_conteudo varchar2 default null,
							        prm_ligacao varchar2 default null,
                                    prm_action varchar2 default 'del' );

	procedure list_filtro_notify ( prm_notify varchar2 default null,
                                   prm_limitado varchar2 default 'N' );

    procedure exec_query ( p_query in varchar2 DEFAULT NULL,
                           p_parse in varchar2 default null,
                           p_linhas in varchar2 default '11' );

	PROCEDURE upload ( prm_alternativo varchar2 default null );


    PROCEDURE download;

    Procedure Download ( arquivo  In  Varchar2 );

	Procedure DownloadOpen ( arquivo  In  Varchar2 );

    procedure download_tab (  prm_arquivo     varchar2 default null,
                              prm_alternativo varchar2 default null );

	procedure uploaded ( prm_chave varchar2 default null );

	procedure remove_image ( prm_img varchar2 default null,
                             prm_user varchar2 default null	);

	procedure save_pos_org ( prm_obj varchar2 default null,
                          prm_posx varchar2 default 50,
                          prm_posy varchar2 default 50 );

	procedure datalist ( prm_coluna varchar2 default null,
                         prm_visao varchar2 default null );

	procedure update_file ( prm_objeto varchar2 default null,
                            prm_valor varchar2 default null );
	procedure clone_screen (prm_objeto varchar2 default null);

	function clone_object (prm_objeto 	varchar2 default null, prm_codigo number default null) return varchar2;

	PROCEDURE QUICK_CREATE ( PRM_NOME       VARCHAR2 DEFAULT NULL,
                         PRM_TIPO       VARCHAR2 DEFAULT NULL,
                         PRM_PARAMETROS VARCHAR2 DEFAULT NULL,
                         PRM_VISAO      VARCHAR2 DEFAULT NULL,
                         PRM_COLUNA     VARCHAR2 DEFAULT NULL,
						 PRM_GRUPO      VARCHAR2 DEFAULT NULL,
						 PRM_OBJ_ANT    VARCHAR2 DEFAULT NULL,
                         PRM_FILTRO     VARCHAR2 DEFAULT NULL); 

	procedure change_bar ( prm_obj varchar2 default null,
                           prm_agrupador varchar2 default null,
					       prm_tipo varchar2 default 'objeto' );

	procedure countdown ( prm_screen varchar2 default null );
	
	procedure background_attrib_monta ( prm_screen  in     varchar2 default null,
                                        prm_valores in out varchar2  ) ;

	procedure background_attrib ( prm_screen varchar2 default null );
	
	procedure update_language ( prm_valor varchar2 default null,
                                prm_tabela varchar2 default null,
                                prm_coluna varchar2 default null,
                                prm_linguagem varchar2 default null,
                                prm_default varchar2 default null,
                                prm_tipo varchar2 default null );

	procedure screen_list ( prm_objeto varchar2 default 'N/A' );

	procedure linguagem_padrao ( prm_update char default 'N',
                             prm_tabela varchar2 default null,
							 prm_coluna varchar2 default null,
							 prm_linguagem varchar2 default null,
							 prm_default varchar2 default null,
                             prm_fixa char default null );

	Procedure PASS_LANG;

	procedure clearlog ( prm_programa varchar2 default 'JS' );


	procedure processos ( prm_completo varchar2 default 'N' );

	procedure acessos ( prm_completo varchar2 default 'N' );

	procedure logs;

	procedure logs_lista ( prm_tipo varchar2 default null,
	                       prm_usuario varchar2 default null,
	                       prm_linha number default 30,
						   prm_order varchar2 default '2',
						   prm_dir varchar2 default '2');

	/*procedure update_tool ( prm_tool varchar2 default null,
                        prm_hint varchar2 default null,
                        prm_ativo varchar2 default 'N' );*/

	procedure change_pass (usuario  varchar2, senha    varchar2 );

	Procedure Xsend_Mail ( Prm_Sender    In Varchar2,
                           Prm_Recipient In Varchar2,
                           Prm_Subject   In Varchar2,
                           Prm_Message   In Varchar2,
						   Prm_erro_envio in out Varchar2  );

	Procedure xsend_mail_upquery ( prm_param       in     varchar2,
						  	   	   Prm_erro_envio  in out Varchar2) ;

	procedure edit_filtro ( prm_key number default null,
		                    prm_valor varchar2 default null,
							prm_tipo varchar2 default null);

    procedure edit_destaque ( prm_key      number default null,
	                          prm_valor    varchar2 default null,
							  prm_acao     varchar2 default null );

	procedure obj_on_screen ( prm_screen varchar2 default null );

	procedure dashboardmove ( prm_objeto varchar2 default null,
                              prm_target varchar2 default null,
						      prm_last varchar2 default null );

	procedure clear_sandbox;

	procedure executar(  prm_acao varchar2 default null );

	/*procedure show_access ( prm_usuario  varchar2 default null, 
	                        prm_conteudo varchar2 default 'FULL' );*/

	procedure show_update ( prm_usuario varchar2 default null,
                        prm_screen varchar2 default null,
						prm_time varchar2 default null,
						prm_ordem varchar2 default '1',
						prm_tipo  varchar2 default 'all' );

	procedure fakedatalist ( prm_codigo     varchar2 default null,
	                         prm_descricao  varchar2 default null,
							 prm_tabela     varchar2 default null,
	                         prm_rownum     number default 50,
							 prm_text       varchar2 default 'N/A',
	                         prm_browser    varchar2 default 'N/A' );

	procedure dl_view ( prm_view varchar2 default null );

	PROCEDURE Send_Sms ( Prm_Origem  Varchar2 Default Null,
                         Prm_Msg     Varchar2 Default Null,
                         PRM_FONE    VARCHAR2 DEFAULT NULL,
                         prm_count   varchar2 default 'NO_NUM' );

	procedure check_data ( prm_valor varchar2 default null,
                           prm_tabela varchar2 default null,
					       prm_true varchar2 default 'ok',
					       prm_false varchar2 default 'error' );

	procedure HTML_CONSULTA ( prm_visao varchar2 default null,
                                  prm_objid varchar2 default null,
								  prm_screen varchar2 default null,
                                  prm_drill varchar2 default 'Y',
  								  prm_ordem number default 1,
								  prm_posx varchar2 default null,
                                  prm_posy varchar2 default null,
								  prm_dashboard varchar2 default null);

	procedure object_padrao;

	procedure add_object_padrao (  prm_obj         varchar2 default null,
								   prm_propriedade varchar2 default null,
								   prm_tipo        varchar2 default null,
								   prm_label       varchar2 default null,
								   prm_default     varchar2 default null,
								   prm_sufixo      varchar2 default 'gr',
								   prm_script      varchar2 default 'rtl',
								   prm_validacao   varchar2 default null,
								   prm_grupo       varchar2 default 'VISUAL' );

	procedure update_padrao ( prm_tipo varchar2 default null,
                              prm_propriedade varchar2 default null,
						      prm_coluna varchar2 default null,
						      prm_valor varchar2 default null );

	procedure painel;

	procedure gera_conteudo (  ws_excel in out clob,
                               prm_saida varchar2 default null,
						       prm_excel varchar2 default null,
						       prm_pdf varchar2 default null,
						       prm_csv varchar2 default null );

	procedure lang_table;

	procedure update_lang_table ( prm_default varchar2 default null,
	                            prm_texto varchar2 default null,
								prm_linguagem varchar2 default null );

	procedure list_obj  ( prm_tipo varchar2 default 'N/A',
                          prm_view varchar2 default 'N/A',
					      prm_grupo varchar2 default 'N/A',
					      prm_desc varchar2 default 'N/A' );

	procedure template ( prm_objeto varchar2 default null,
                         prm_valor varchar2 default null,
					     prm_view  varchar2 default null );

	procedure sqlparse;

	procedure mapmarker ( prm_objeto varchar2 default null );

	procedure favoritar ( prm_favorito   number   default null,
                      prm_objeto     varchar2 default null,
					  prm_nome       varchar2 default null,
					  prm_url        varchar2 default null,
					  prm_screen     varchar2 default null,
					  prm_parametros varchar2 default null,
					  prm_dimensao   varchar2 default null,
					  prm_medida     varchar2 default null,
					  prm_pivot      varchar2 default null,
					  prm_acao       varchar2 default 'incluir' );

					  

	procedure passagem_test ( picado IN owa_util.vc_arr,
                              nome varchar2 default null,
                              parseonly varchar2 default 'S' );

	procedure Forcelogoff ( prm_nome varchar2 default null, prm_session varchar2 default null );

	procedure VERIFICA_JOB;
	
	PROCEDURE REG_PULSE;
	
	procedure PUT_VAR ( PRM_VARIAVEL VARCHAR2 DEFAULT NULL,
                        PRM_CONTEUDO VARCHAR2 DEFAULT NULL );

    procedure loginScreen;

	procedure qrmanual ( prm_session varchar2 default null,
                         prm_check   varchar2 default null );

	procedure qrcheck ( prm_session varchar2 default null );

	procedure checkpar ( prm_variavel varchar2 default null,
                         prm_visao    varchar2 default null );

	procedure admin_options;

	procedure admin_alter ( prm_usuario   varchar2 default null,
                            prm_permissao varchar2 default null );

	
    procedure condicoes ( prm_tipo     varchar2 default null,
                          prm_condicao varchar2 default null );

    procedure carrega_objeto ( prm_tipo      varchar2 default null,
	                           prm_posicao   varchar2 default null,
	                           prm_parametro varchar2 default null,
	                           prm_visao     varchar2 default null,
	                           prm_coluna    varchar2 default null,
	                           prm_agrupador varchar2 default null,
	                           prm_tip       varchar2 default null,
	                           prm_obj       varchar2 default null,
	                           prm_screen    varchar2 default null,
	                           prm_colup     varchar2 default null );

    procedure dashboardcopy ( prm_dashboard varchar2 default null, 
                              prm_actual    varchar2 default null );

    procedure title_screen ( prm_screen varchar2 default null );

    procedure obj_screen_count ( prm_screen varchar2 default null,
                                 prm_tipo   varchar2 default null );

	procedure lista_objetos;

    PROCEDURE PADRAO_COLUNAS (  prm_tabela      varchar2,
                                prm_micro_visao varchar2 );
    
    procedure prefixo_lista;

    procedure prefixo_alter ( prm_prefixo         varchar2 default null, 
	                          prm_lov             varchar2 default null,
	                          prm_lovp            varchar2 default null,
	                          prm_agrupador       varchar2 default null,
	                          prm_mascara         varchar2 default null,
	                          prm_alinhamento     varchar2 default null,
	                          prm_prefixo_ant     varchar2 default null, 
	                          prm_lov_ant         varchar2 default null,
	                          prm_lovp_ant        varchar2 default null,
	                          prm_agrupador_ant   varchar2 default null,
	                          prm_mascara_ant     varchar2 default null,
	                          prm_alinhamento_ant varchar2 default null,
	                          prm_evento          varchar2 default null );
    
    procedure remove_coluna ( prm_visao varchar2 default null );
    
    procedure fakeoption ( prm_id          varchar2 default null,
							prm_placeholder varchar2 default null,
							prm_valor       varchar2 default null,
							prm_opcao       varchar2 default null,
							prm_editable    varchar2 default null,
							prm_multi       varchar2 default null,
							prm_visao       varchar2 default null,
							prm_fixed       varchar2 default null,
							prm_adicional   varchar2 default null,
							prm_desc        varchar2 default null,
							prm_reverse     varchar2 default null,
							prm_children    varchar2 default null,
							prm_min         number   default null,
							prm_encode      varchar2  default 'N',
							prm_img         varchar2 default null );
						  
    
    procedure update_prop ( prm_id     varchar2 default null,
							prm_prop   varchar2 default null,
							prm_valor  varchar2 default null,
							prm_screen varchar2 default null );
    
    procedure check_acl ( prm_host      varchar2 default null,
		                  prm_port_lower varchar2 default null,
		                  prm_port_upper varchar2 default null  );
						  
    
    procedure replace_binds ( prm_query varchar2 default null, 
                              prm_binds varchar2 default null );

	procedure lista_cidades ( prm_estado varchar2 default null,
                              prm_coluna varchar2 default 'CD',
							  prm_obj    varchar2 default null,
						      prm_screen varchar2 default null,
						      prm_visao  varchar2 default null,
							  prm_parametros varchar2 default null );
	
	procedure lista_estados ( prm_estado varchar2 default null,
                              prm_coluna varchar2 default 'CD',
							  prm_obj    varchar2 default null,
						      prm_screen varchar2 default null,
						      prm_visao  varchar2 default null,
							  prm_parametros varchar2 default null );
							  
	procedure data_attrib ( prm_objeto varchar2 default null,
							prm_tipo   varchar2 default null,
							prm_screen varchar2 default null );
							
	procedure broken_job ( prm_num varchar2 default null );
	
	procedure svg ( prm_cod number default 99 );

	procedure favoritos ( prm_screen varchar2 default null );

	procedure popupMenu ( prm_tipo varchar2 default null,
                          prm_cond varchar2 default null );

	procedure perfil;

	procedure alerta;

	PROCEDURE USERINFO ( PRM_NOME  VARCHAR2 DEFAULT NULL,
						 PRM_EMAIL VARCHAR2 DEFAULT NULL,
						 PRM_CELL  VARCHAR2 DEFAULT NULL,
						 PRM_NOTIFICACAO VARCHAR2 DEFAULT NULL ) ; 

	procedure release_version ( prm_version varchar2 default null );

	procedure button_lixo ( prm_req      varchar2 default null,
							prm_parm     varchar2 default null,	
							prm_valores  varchar2 default null,
							prm_vldecode number   default null,
							prm_objeto   varchar2 default null,
							prm_tag      varchar2 default 'a',
							prm_pkg      varchar2 default 'FCL' );

	procedure jumpdrill ( prm_objeto  varchar2, 
						  prm_colunas varchar2 default null,
						  prm_visao   varchar2 default null,
					  	  prm_objeto_ant varchar2 default null );

	procedure jumpmed ( prm_coluna varchar2 default null,
						prm_visao  varchar2 default null, 
						prm_objeto varchar2 default null );

	procedure listaCustomizado ( prm_usuario  varchar2 default null );

	procedure addCustomizado ( prm_usuario  varchar2 default null,
                               prm_visao    varchar2 default null,
						       prm_colunas  varchar2 default null );

	procedure deletaCustomizado ( prm_chave  number );

	procedure deletaCustom ( prm_custom  number );

	procedure geraCustomizado( prm_custom       number   default 0,
							   prm_visao        varchar2 default null,
							   prm_coluna_agrup varchar2 default null,
							   prm_coluna_valor varchar2 default null,
							   prm_coluna_pivot varchar2 default null,
							   prm_coluna_tipo  varchar2 default null,
							   prm_limite       varchar2 default null,
							   filtropipe       varchar2 default null,
							   prm_tipo         varchar2 default 'show',
							   prm_desc         varchar2 default null );

	procedure conteudoCustomizado;

	procedure subparReal ( prm_texto  varchar2 default null,
                       	   prm_screen varchar2 default null );

	procedure adicionaCustomizado ( prm_custom       number   default null,
									prm_visao        varchar2 default null,
									prm_coluna_agrup varchar2 default null,
									prm_coluna_valor varchar2 default null,
									prm_coluna_pivot varchar2 default null,
									prm_coluna_tipo  varchar2 default null,
									prm_limite       varchar2 default null,
									filtropipe       varchar2 default null,
									prm_desc         varchar2 default null,
									prm_grupo        varchar2 default null );

	procedure fakeCustom ( prm_tipo   varchar2 default null,
                           prm_search varchar2 default null,
						   prm_extend varchar2 default null );

	procedure auto_update;

	procedure updateAuto ( prm_tipo varchar2 default null,
                           prm_auto varchar2 default 'N' );

    procedure login ( prm_user     varchar2 default null,
				 	  prm_password varchar2 default null, 
					  prm_session  varchar2 default null,
					  prm_prazo    number   default 0.5,
					  prm_url      varchar2 default null );

	procedure newPassword ( prm_usuario varchar2,
							prm_code 	varchar2   default null,
							prm_url  	varchar2 default null );

	procedure loginValida ( prm_usuario 	varchar2,
    	                    prm_code    	varchar2 default null,
							prm_url     	varchar2 default null,
							prm_msg_retorno in out varchar2 ) ;							

	procedure copiarPermissaoBox ( prm_usuario varchar2 default null );

	procedure copiarPermissao ( prm_usuario varchar2, 
								prm_usuario_cop varchar2, 
								prm_status varchar2 default 'manter' );

	procedure listContainer;

	procedure numericOptions( prm_number   number default 20,
					 	 prm_selected number default 0 );

end FCL;
/
show error