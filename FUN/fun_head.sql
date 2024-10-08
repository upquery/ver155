set define off
create or replace package FUN is

    FUNCTION RET_LIST (	PRM_CONDICOES VARCHAR2 DEFAULT NULL,
					    PRM_LISTA	OUT	DBMS_SQL.VARCHAR2_TABLE ) RETURN VARCHAR2;
					
	FUNCTION VPIPE ( PRM_ENTRADA VARCHAR2,
                     PRM_DIVISAO VARCHAR2 DEFAULT '|' ) RETURN CHARRET PIPELINED;
					 
	FUNCTION RET_VAR ( PRM_VARIAVEL VARCHAR2 DEFAULT NULL, PRM_USUARIO VARCHAR2 DEFAULT 'DWU' ) RETURN VARCHAR2;
	
	FUNCTION GETSESSAO  ( PRM_COD VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

	PROCEDURE SETSESSAO ( PRM_COD   VARCHAR2 DEFAULT NULL,
                          PRM_VALOR VARCHAR2 DEFAULT NULL,
                          PRM_DATA  DATE     DEFAULT NULL );
	
	PROCEDURE SET_VAR  ( PRM_VARIAVEL   VARCHAR2 DEFAULT NULL,
                     PRM_CONTEUDO   VARCHAR2 DEFAULT NULL,
                     PRM_USUARIO    VARCHAR2 DEFAULT 'DWU' );

    FUNCTION GVALOR( PRM_OBJETO VARCHAR2 DEFAULT NULL, PRM_SCREEN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION CHECK_BLINK ( PRM_OBJETO    VARCHAR2 DEFAULT NULL,
                       PRM_COLUNA    VARCHAR2 DEFAULT NULL,
                       PRM_CONTEUDO  VARCHAR2 DEFAULT NULL,
                       PRM_ORIGINAL  VARCHAR2 DEFAULT NULL,
                       PRM_SCREEN    VARCHAR2 DEFAULT NULL,
                       PRM_USUARIO   VARCHAR2 DEFAULT NULL ) RETURN CHAR;

	PROCEDURE BLINK_CONDITION ( PRM_CONDICAO  IN  VARCHAR2,
								PRM_VALOR     IN  VARCHAR2,
								PRM_CONTEUDO  IN  VARCHAR2,
								PRM_COR_FUNDO IN  VARCHAR2,
								PRM_COR_FONTE IN  VARCHAR2,
								WS_SAIDA      OUT VARCHAR2,
								WS_COR_FUNDO  OUT VARCHAR2,
								WS_COR_FONTE  OUT VARCHAR2,
								PRM_ORIGINAL  IN  VARCHAR2);
	
	FUNCTION CHECK_BLINK_TOTAL ( PRM_OBJETO   VARCHAR2 DEFAULT NULL,
                                 PRM_COLUNA   VARCHAR2 DEFAULT NULL,
                                 PRM_CONTEUDO VARCHAR2 DEFAULT NULL,
                                 PRM_ORIGINAL VARCHAR2 DEFAULT NULL,
                                 PRM_SCREEN   VARCHAR2 DEFAULT NULL ) RETURN CHAR;
	
	FUNCTION CHECK_BLINK_LINHA ( PRM_OBJETO   VARCHAR2 DEFAULT NULL,
                                 PRM_COLUNA   VARCHAR2 DEFAULT NULL,
                                 PRM_LINHA    VARCHAR2 DEFAULT NULL,
                                 PRM_CONTEUDO VARCHAR2 DEFAULT NULL,
                                 PRM_SCREEN   VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
    FUNCTION WACESSO ( PRM_WHO VARCHAR2 DEFAULT 'ALL') RETURN CHARRET PIPELINED;

    FUNCTION WHO RETURN VARCHAR;	
	
	FUNCTION GPARAMETRO ( PRM_PARAMETRO VARCHAR2 DEFAULT NULL, 
                          PRM_DESC      VARCHAR2 DEFAULT 'N',
                          PRM_SCREEN    VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
    FUNCTION GFORMULA ( prm_texto        varchar2 default null,
						prm_micro_visao  varchar2 default null,
						prm_agrupador    varchar2 default null,
						prm_inicio       varchar2 default 'NO',
						prm_final        varchar2 default 'NO',
						prm_screen       varchar2 default null,
						prm_recurs       varchar2 default null,
						prm_flexcol      varchar2 default 'N',
						prm_flexend      varchar2 default 'N' ) return varchar2;

	FUNCTION GFORMULA2 ( PRM_MICRO_VISAO  VARCHAR2 DEFAULT NULL,
	                     PRM_COLUNA       VARCHAR2 DEFAULT NULL,
	                     PRM_SCREEN       VARCHAR2 DEFAULT NULL,
	                     PRM_INSIDE       VARCHAR2 DEFAULT 'N',
	                     PRM_OBJETO       VARCHAR2 DEFAULT NULL,
                         PRM_INICIO       VARCHAR2 DEFAULT NULL,
                         PRM_FINAL        VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

	
	FUNCTION URL_DEFAULT ( PRM_PARAMETROS	IN  LONG,
					       PRM_MICRO_VISAO	IN  LONG,
					       PRM_AGRUPADORES	IN OUT LONG,
					       PRM_COLUNA		IN OUT LONG,
					       PRM_RP		    IN OUT LONG,
					       PRM_COLUP		IN OUT LONG,
					       PRM_COMANDO		IN  LONG,
					       PRM_MODE		    IN OUT LONG ) RETURN VARCHAR2;

    FUNCTION VALOR_PONTO (  PRM_PARAMETROS   VARCHAR2 DEFAULT NULL,
						    PRM_MICRO_VISAO	 VARCHAR2 DEFAULT NULL,
						    PRM_OBJETO		 VARCHAR2 DEFAULT NULL, 
						    PRM_SCREEN       VARCHAR2 DEFAULT NULL ) RETURN CHAR;	

    
    FUNCTION CDESC ( PRM_CODIGO CHAR  DEFAULT NULL,
	                 PRM_TABELA CHAR DEFAULT NULL,
	                 PRM_REVERSE BOOLEAN DEFAULT FALSE ) RETURN VARCHAR2;		

    FUNCTION GETPROP ( PRM_OBJETO  VARCHAR2,
					   PRM_PROP    VARCHAR2,
					   PRM_SCREEN  VARCHAR2 DEFAULT 'DEFAULT',
                       PRM_USUARIO VARCHAR2 DEFAULT 'DWU',
                       PRM_TIPO    VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 RESULT_CACHE;

	FUNCTION GETPROPS (  PRM_OBJETO  VARCHAR2,
						 PRM_TIPO    VARCHAR2,
						 PRM_PROP    VARCHAR2,
						 PRM_USUARIO VARCHAR2 DEFAULT 'DWU' ) RETURN ARR RESULT_CACHE;	

    FUNCTION PUT_STYLE ( PRM_OBJETO    VARCHAR2,
					     PRM_PROP      VARCHAR2,
					     PRM_TP_OBJETO VARCHAR2,
					     PRM_VALUE     VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 RESULT_CACHE;	

    FUNCTION RET_SINAL ( PRM_OBJETO    VARCHAR2,
					     PRM_COLUNA    VARCHAR2,
					     PRM_CONTEUDO  VARCHAR2 ) RETURN VARCHAR2;	

    FUNCTION PUT_PAR ( PRM_OBJETO     VARCHAR2,
					   PRM_PROP       VARCHAR2,
					   PRM_TP_OBJETO  VARCHAR2,
					   PRM_OWNER      VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

    FUNCTION COL_NAME (	PRM_CD_COLUNA   VARCHAR2 DEFAULT NULL,
						PRM_MICRO_VISAO VARCHAR2,
						PRM_CONDICAO	VARCHAR2 DEFAULT '',
						PRM_CONTEUDO	VARCHAR2,
						PRM_COLOR VARCHAR2 DEFAULT '#000000',
						PRM_TITLE VARCHAR2 DEFAULT 'Filtro do drill',
						PRM_REPEAT BOOLEAN DEFAULT FALSE,
						PRM_AGRUPADO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR;

    FUNCTION CHECK_USER ( PRM_USUARIO VARCHAR2 DEFAULT USER ) RETURN BOOLEAN;			
	
	FUNCTION VCALC ( PRM_CD_COLUNA   VARCHAR2,
				     PRM_MICRO_VISAO VARCHAR2 ) RETURN BOOLEAN;
	
	FUNCTION XCALC ( PRM_CD_COLUNA    VARCHAR2, 
                     PRM_MICRO_VISAO  VARCHAR2, 
                     PRM_SCREEN       VARCHAR2 ) RETURN VARCHAR2;
	
	FUNCTION XEXEC (  WS_CONTENT  VARCHAR2 DEFAULT NULL, 
	                  PRM_SCREEN  VARCHAR2 DEFAULT NULL, 
					  PRM_ATUAL   VARCHAR2 DEFAULT NULL, 
					  PRM_ANT     VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION SETEM ( PRM_STR1 VARCHAR2,
				     PRM_STR2 VARCHAR2 ) RETURN BOOLEAN;
	
    FUNCTION ISNUMBER ( PRM_VALOR VARCHAR2 DEFAULT NULL ) RETURN BOOLEAN;
		
	FUNCTION IFMASCARA ( STR1 IN VARCHAR2,
						 CMASCARA VARCHAR2,
						 PRM_CD_MICRO_VISAO VARCHAR2 DEFAULT '$[no_mv]',
						 PRM_CD_COLUNA VARCHAR2 DEFAULT '$[no_co]',
						 PRM_OBJETO VARCHAR2 DEFAULT '$[no_ob]',
						 PRM_TIPO VARCHAR2 DEFAULT 'micro_coluna',
						 PRM_FORMULA VARCHAR2 DEFAULT NULL,
						 PRM_SCREEN  VARCHAR2 DEFAULT NULL,
						 PRM_USUARIO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

	FUNCTION MASCARAJS ( PRM_MASCARA VARCHAR2, PRM_TIPO VARCHAR2 DEFAULT 'texto' ) RETURN VARCHAR2;
	
	FUNCTION UM ( PRM_COLUNA  VARCHAR2 DEFAULT '$[no_co]',
                  PRM_VISAO   VARCHAR2 DEFAULT '$[no_ob]',
                  PRM_CONTENT VARCHAR2 DEFAULT NULL,
                  PRM_UM      VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
		
	FUNCTION IFNOTNULL ( STR1 IN VARCHAR2, STR2 IN VARCHAR2 ) RETURN VARCHAR2;
	
	FUNCTION VERIFICA_DATA ( CHK_DATA VARCHAR DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION R_GIF ( PRM_GIF_NOME  VARCHAR2 DEFAULT NULL,
                     PRM_TYPE      VARCHAR2 DEFAULT 'GIF',
                     PRM_LOCATION  VARCHAR2 DEFAULT 'LOCAL' ) RETURN VARCHAR2;
	
	FUNCTION SUBPAR ( PRM_TEXTO VARCHAR2 DEFAULT NULL, 
		              PRM_SCREEN VARCHAR2 DEFAULT NULL, 
		              PRM_DESC VARCHAR2 DEFAULT 'Y') RETURN VARCHAR2;
	
	FUNCTION CALL_DRILL ( PRM_DRILL VARCHAR DEFAULT 'N', 
						  PRM_PARAMETROS LONG,
						  PRM_SCREEN LONG,
						  PRM_OBJID CHAR DEFAULT NULL,
						  PRM_MICRO_VISAO CHAR DEFAULT NULL,
						  PRM_COLUNA CHAR DEFAULT NULL,
						  PRM_SELECTED NUMBER DEFAULT 1,
						  PRM_TRACK VARCHAR2 DEFAULT NULL, 
						  PRM_OBJETON VARCHAR2 DEFAULT NULL ) RETURN CLOB;
	
	FUNCTION NOME_COL ( PRM_CD_COLUNA   VARCHAR2,
                        PRM_MICRO_VISAO VARCHAR2, 
                        PRM_SCREEN      VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

	
	FUNCTION MAPOUT ( PRM_PARAMETROS   VARCHAR2 DEFAULT NULL,
					  PRM_MICRO_VISAO  CHAR DEFAULT NULL,
					  PRM_COLUNA       CHAR DEFAULT NULL,
					  PRM_AGRUPADOR    CHAR DEFAULT NULL,
					  PRM_MODE         CHAR DEFAULT 'NO',
					  PRM_OBJETO       VARCHAR2 DEFAULT NULL,
					  PRM_SCREEN       VARCHAR2 DEFAULT NULL,
					  PRM_COLUP        VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
					  
	
	FUNCTION VPIPE_PAR ( PRM_ENTRADA VARCHAR ) RETURN TAB_PARAMETROS PIPELINED;
	
	FUNCTION SHOW_FILTROS ( PRM_CONDICOES    VARCHAR2 DEFAULT NULL,
							PRM_CURSOR       NUMBER   DEFAULT 0,
							PRM_TIPO         VARCHAR2 DEFAULT 'ATIVO',
							PRM_OBJETO       VARCHAR2 DEFAULT NULL,
							PRM_MICRO_VISAO  VARCHAR2 DEFAULT NULL,
							PRM_SCREEN       VARCHAR2 DEFAULT NULL,
							PRM_USUARIO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
							
	FUNCTION SHOW_DESTAQUES ( PRM_CONDICOES   VARCHAR2 DEFAULT NULL,
							  PRM_CURSOR      NUMBER   DEFAULT 0,
							  PRM_TIPO        VARCHAR2 DEFAULT 'ATIVO',
							  PRM_OBJETO      VARCHAR2 DEFAULT NULL,
							  PRM_MICRO_VISAO VARCHAR2 DEFAULT NULL,
							  PRM_SCREEN      VARCHAR2 DEFAULT NULL,
                          	  PRM_USUARIO     VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION PUT_VAR ( PRM_VARIAVEL VARCHAR2 DEFAULT NULL,
                       PRM_CONTEUDO VARCHAR2 DEFAULT NULL )  RETURN VARCHAR2;
	
	FUNCTION CHECK_SYS  RETURN VARCHAR2;
	
	FUNCTION RCONDICAO ( PRM_VARIAVEL VARCHAR) RETURN CHAR;
	
	FUNCTION DCONDICAO ( PRM_VARIAVEL VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION CONVERT_PAR  ( PRM_VARIAVEL  VARCHAR2,
                            PRM_ASPAS     VARCHAR2 DEFAULT NULL,
						    PRM_SCREEN    VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION SUBVAR ( PRM_TEXTO VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
	
	FUNCTION CHECK_NETWALL ( PRM_USER VARCHAR2 DEFAULT NULL ) RETURN BOOLEAN;
	
	FUNCTION APPLY_DRE_MASC ( PRM_MASC   VARCHAR DEFAULT NULL,
                              PRM_STRING VARCHAR DEFAULT NULL ) RETURN VARCHAR2;
	
	PROCEDURE EXECUTE_NOW ( PRM_COMANDO  VARCHAR2 DEFAULT NULL,
                        	PRM_REPEAT  VARCHAR2 DEFAULT  'S' );
	
	FUNCTION GL_CALCULADA ( PRM_TEXTO        VARCHAR2 DEFAULT NULL,
                            PRM_CD_COLUNA    VARCHAR2 DEFAULT NULL,
                            PRM_VL_AGRUPADOR VARCHAR2 DEFAULT NULL,
							PRM_TABELA       VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION LIST_POST ( PRM_OBJETO     VARCHAR2 DEFAULT NULL,
                         PRM_PARAMETROS VARCHAR2 DEFAULT NULL,
					     PRM_GROUP      VARCHAR2 DEFAULT NULL ) RETURN TAB_MENSAGENS PIPELINED;
	
	FUNCTION LIST_ALL_POST ( PRM_PARAMETROS VARCHAR2 DEFAULT NULL,
                             PRM_GROUP      VARCHAR2 DEFAULT NULL ) RETURN TAB_MENSAGENS PIPELINED;
	
	FUNCTION VERIFICA_POST ( PRM_OBJETO     VARCHAR2 DEFAULT NULL,
                             PRM_PARAMETROS VARCHAR2 DEFAULT NULL ) RETURN BOOLEAN;
	
	FUNCTION EXT_MASC ( PRM_VALUE VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION INIT_TEXT_POST RETURN NUMBER;
	
	FUNCTION CHECK_PERMISSAO ( PRM_OBJETO VARCHAR2 DEFAULT NULL, PRM_USUARIO VARCHAR2 DEFAULT NULL) RETURN CHAR;
	
	FUNCTION C2B( P_CLOB IN CLOB ) RETURN BLOB;
	
	FUNCTION NSLOOKUP ( PRM_ENDERECO VARCHAR DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION LANG ( PRM_TEXTO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION GET_TRANSLATOR ( PRM_TEXTO        VARCHAR2,
                              PRM_ORIGEM_LANG  VARCHAR2,
                              PRM_DESTINO_LANG VARCHAR2 ) RETURN VARCHAR2;

	FUNCTION RET_PAR ( PRM_SESSAO VARCHAR2 ) RETURN VARCHAR2;
	
	FUNCTION UTRANSLATE ( PRM_CD_COLUNA VARCHAR2,
						  PRM_TABELA    VARCHAR2,
						  PRM_DEFAULT   VARCHAR2,
                          PRM_PADRAO    VARCHAR2 DEFAULT 'PORTUGUESE' ) RETURN VARCHAR2;
	
	FUNCTION LIST_VIEW ( PRM_TIPO CHAR DEFAULT NULL ) RETURN VARCHAR2;
	
	PROCEDURE REQUEST_PROGS;
	
	FUNCTION CONVERT_CALENDAR ( PRM_VALOR VARCHAR2 DEFAULT NULL,
                                PRM_TIPO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION XFORMULA ( PRM_TEXTO  VARCHAR2 DEFAULT NULL, 
                        PRM_SCREEN VARCHAR2 DEFAULT NULL,
                        PRM_SPACE  VARCHAR2 DEFAULT 'N' ) RETURN VARCHAR2;
	
	FUNCTION URLENCODE ( P_STR IN VARCHAR2 ) RETURN VARCHAR2;

	
	FUNCTION CHECK_ROTULOC ( PRM_COLUNA VARCHAR2 DEFAULT NULL,
                             PRM_VISAO VARCHAR2 DEFAULT NULL,
						     PRM_SCREEN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

	
	FUNCTION CONV_TEMPLATE ( PRM_MICRO_VISAO VARCHAR2 DEFAULT NULL,
                             PRM_AGRUPADORES VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION B2C ( P_BLOB BLOB ) RETURN CLOB;
	
	FUNCTION CLEAR_PARAMETRO ( PRM_PARAMETROS VARCHAR2 DEFAULT NULL ) RETURN CLOB;
	
	FUNCTION CHECK_SESSION RETURN VARCHAR2;
	
	FUNCTION SEND_ID ( PRM_CLIENTE VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION CHECK_ID ( PRM_CHAVE VARCHAR2 DEFAULT NULL, PRM_CLIENTE VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION CHECK_TOKEN ( PRM_CHAVE VARCHAR2 DEFAULT NULL, PRM_CLIENTE VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION SHOWTAG ( PRM_OBJ VARCHAR2 DEFAULT NULL,
                       PRM_TAG VARCHAR2 DEFAULT NULL,
				       PRM_OUTRO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION CHECK_VALUE ( PRM_VALOR VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION PTG_TRANS ( PRM_TEXTO IN VARCHAR2 ) RETURN VARCHAR2;
	
	FUNCTION EXCLUIR_DASH ( PRM_OBJETO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION CHECK_ADMIN ( PRM_PERMISSAO VARCHAR2 DEFAULT NULL ) RETURN BOOLEAN;

    FUNCTION GET_SEQUENCE ( PRM_TABELA VARCHAR2 DEFAULT NULL,
                            PRM_COLUNA VARCHAR2 DEFAULT NULL ) RETURN NUMBER;

    
    FUNCTION ATTRIB_TEMPOREAL ( PRM_ATRIB VARCHAR2 DEFAULT NULL, 
	                            PRM_OBJ   VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
								
	FUNCTION ERROR_RESPONSE ( PRM_ERROR VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
						
    


	

	FUNCTION CHECK_SCREEN_ACCESS ( PRM_SCREEN  VARCHAR2 DEFAULT NULL, 
                                   PRM_USUARIO VARCHAR2 DEFAULT NULL, 
                                   PRM_ADMIN   VARCHAR2 DEFAULT NULL ) RETURN NUMBER;

    FUNCTION VPIPE_ORDER ( PRM_ENTRADA VARCHAR2,
                           PRM_DIVISAO VARCHAR2 DEFAULT '|' ) RETURN TAB_PIPE PIPELINED;	

    
	FUNCTION AV_COLUMNS ( PRM_OBJ        VARCHAR2 DEFAULT NULL,
                          PRM_SCREEN     VARCHAR2 DEFAULT NULL,
					      PRM_CONDICOES  VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
						  
	FUNCTION TEST_COLUMNS ( PRM_VALOR  VARCHAR2 DEFAULT NULL,
                            PRM_TABELA VARCHAR2 DEFAULT NULL,
						    PRM_VISAO  VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
	
	FUNCTION GET_QDATA ( PRM_DIMENSOES   VARCHAR2 DEFAULT NULL,
                         PRM_MEDIDAS     VARCHAR2 DEFAULT NULL,
                         PRM_FILTROS     VARCHAR2 DEFAULT NULL,
                         PRM_MICRO_VISAO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

	FUNCTION CREATE_USER ( USERNAME         IN VARCHAR2, 
					       PASSWORD         IN VARCHAR2,
					       PRM_REFERENCIA   IN VARCHAR2 DEFAULT NULL,
					       PRM_EMAIL        IN VARCHAR2,
					       PRM_COMPLETO     IN VARCHAR2  ) RETURN VARCHAR2;

	FUNCTION REMOVE_USER ( PRM_USUARIO VARCHAR2 ) RETURN VARCHAR2;

	FUNCTION CONVERTE( PRM_TEXTO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

	FUNCTION NOMEOBJETO( PRM_OBJETO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

	FUNCTION USUARIO RETURN VARCHAR2;

	

	FUNCTION RANDOMCODE( PRM_TAMANHO NUMBER DEFAULT 10) RETURN VARCHAR2;

	FUNCTION OBJCODE ( PRM_ALIAS VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

	FUNCTION TESTDIGESTEDPASSWORD( PRM_USUARIO VARCHAR2, PRM_PASSWORD VARCHAR2 ) RETURN VARCHAR2;

	FUNCTION DIGESTPASSWORD( PRM_USUARIO VARCHAR2, PRM_PASSWORD VARCHAR2 ) RETURN VARCHAR2;

	FUNCTION CONV_DATA( PRM_DATA VARCHAR2) RETURN DATE;

END FUN;