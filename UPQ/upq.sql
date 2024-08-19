set scan off
create or replace PACKAGE BODY UpQuery  IS


PROCEDURE MAIN  ( PRM_PARAMETROS	 VARCHAR2 DEFAULT NULL,
			      PRM_MICRO_VISAO    CHAR DEFAULT NULL,
			      PRM_COLUNA	     CHAR DEFAULT NULL,
			      PRM_AGRUPADOR	     CHAR DEFAULT NULL,
			      PRM_RP		     CHAR DEFAULT 'ROLL',
			      PRM_COLUP	         CHAR DEFAULT NULL,
			      PRM_COMANDO	     CHAR DEFAULT 'MOUNT',
			      PRM_MODE	         CHAR DEFAULT 'NO',
			      PRM_OBJID	         CHAR DEFAULT NULL,
			      PRM_SCREEN	     CHAR DEFAULT 'DEFAULT',
			      PRM_POSX	         CHAR DEFAULT NULL,
			      PRM_POSY	         CHAR DEFAULT NULL,
			      PRM_CCOUNT	     CHAR DEFAULT '0',
			      PRM_DRILL	         CHAR DEFAULT 'N',
			      PRM_ORDEM	         CHAR DEFAULT '0',
			      PRM_ZINDEX	     CHAR DEFAULT 'auto',
                  PRM_TRACK          VARCHAR2 DEFAULT NULL,
                  PRM_OBJETON        VARCHAR2 DEFAULT NULL,
			      PRM_SELF           VARCHAR2 DEFAULT NULL,
				  PRM_DASHBOARD      VARCHAR2 DEFAULT 'false' ) AS

	





	CURSOR CRS_XGOTO(PRM_USUARIO VARCHAR2) IS
			SELECT	RTRIM(CD_OBJETO_GO) AS CD_OBJETO_GO
			FROM 	GOTO_OBJETO WHERE CD_OBJETO = PRM_OBJID AND
			        CD_OBJETO_GO NOT IN ( SELECT CD_OBJETO FROM OBJECT_RESTRICTION WHERE USUARIO = PRM_USUARIO )
			ORDER BY CD_OBJETO_GO;

	WS_XGOTO CRS_XGOTO%ROWTYPE;


	TYPE WS_TMCOLUNAS IS TABLE OF MICRO_COLUNA%ROWTYPE
			    		INDEX BY PLS_INTEGER;

	TYPE GENERIC_CURSOR IS REF CURSOR;

	CRS_SAIDA GENERIC_CURSOR;

	CURSOR NC_COLUNAS IS SELECT * FROM MICRO_COLUNA WHERE CD_MICRO_VISAO = PRM_MICRO_VISAO;

	RET_COLUNA			VARCHAR2(4000);
	WS_COLUNA_SUP       VARCHAR2(4000);
	DAT_COLUNA          DATE;
	RET_MCOL			WS_TMCOLUNAS;
	WS_NCOLUMNS			DBMS_SQL.VARCHAR2_TABLE;
	WS_COLUNA_ANT		DBMS_SQL.VARCHAR2_TABLE;
	WS_PVCOLUMNS		DBMS_SQL.VARCHAR2_TABLE;
	WS_MFILTRO			DBMS_SQL.VARCHAR2_TABLE;
	WS_VCOL				DBMS_SQL.VARCHAR2_TABLE;
	WS_VCON				DBMS_SQL.VARCHAR2_TABLE;
	WS_DRILL			VARCHAR2(40);
	WS_OBJID			VARCHAR2(120);
	WS_ZEBRADO			VARCHAR2(20);
	WS_ZEBRADO_D		VARCHAR2(40);
	WS_QUERYOC			CLOB;
	WS_PIPE				CHAR(1);
	WS_POSX				VARCHAR(5);
	WS_POSY				VARCHAR(5);
	RET_COLUP			LONG;
	WS_LQUERY			NUMBER;
	WS_COUNTERID		NUMBER := 0;
	WS_COUNTER			NUMBER := 1;
	WS_CCOLUNA			NUMBER := 1;
	WS_XCOLUNA			NUMBER := 0;
	WS_CHCOR			NUMBER := 0;
	WS_BINDN			NUMBER := 0;
	WS_SCOL				NUMBER := 0;
	WS_CSPAN			NUMBER := 0;
	WS_XCOUNT			NUMBER := 0;
	WS_CTNULL			NUMBER := 0;
	WS_CTCOL			NUMBER := 0;
	WS_TEXTO			LONG;
	WS_TEXTOT			LONG;
	WS_NM_VAR			LONG;
	WS_CONTENT_ANT		LONG;
	WS_COLUNA_SUP_ANT   VARCHAR2(4000);
	WS_CONTENT			LONG;
	WS_CONTENT_SUM      LONG;
	WS_COLUP			LONG;
	WS_COLUNA			LONG;
	WS_AGRUPADOR		LONG;
	WS_RP				LONG;
	WS_XATALHO			LONG;
	WS_ATALHO			LONG;
	WS_PARAMETROS		LONG;
	WS_ORDEM			VARCHAR2(400);
	WS_ORDEM_QUERY		VARCHAR2(400);
	WS_COUNTOR          NUMBER;
	WS_AGRUPADOR_MAX    NUMBER;
	WS_ACESSO			EXCEPTION;
	WS_SEMQUERY			EXCEPTION;
	WS_SEMPERMISSAO		EXCEPTION;
	WS_PCURSOR			INTEGER;
	WS_CURSOR			INTEGER;
	WS_LINHAS			INTEGER;
	WS_QUERY_MONTADA	DBMS_SQL.VARCHAR2A;
	WS_QUERY_COUNT      DBMS_SQL.VARCHAR2A;
	WS_QUERY_PIVOT		LONG;
	WS_SQL				LONG;
	WS_SQL_PIVOT		LONG;
	
	
	WS_TITULO			VARCHAR2(400);
	WS_NOME             VARCHAR2(400);
	WS_SUBTITULO		VARCHAR2(400);
	
	WS_MODE				VARCHAR2(30);
	WS_IDCOL			VARCHAR2(120);
	WS_CLEARDRILL		VARCHAR2(120);
	WS_FIRSTID			CHAR(1);
	WS_VAZIO			BOOLEAN := TRUE;
	WS_NODATA       	EXCEPTION;
	WS_INVALIDO			EXCEPTION;
	
	WS_CLOSE_HTML	    EXCEPTION;
	WS_MOUNT			EXCEPTION;
	WS_PARSEERR			EXCEPTION;
    WS_NOVA_SESSAO      EXCEPTION;
	WS_POSICAO			VARCHAR2(2000) := ' ';
	WS_DRILL_ATALHO		VARCHAR2(4000);
	WS_CTEMP			VARCHAR2(40);
	WS_TMP_JUMP			VARCHAR2(300);
	WS_JUMP				VARCHAR2(600);
	WS_POSIX			VARCHAR2(80);
	WS_POSIY			VARCHAR2(80);
	WS_SEM				VARCHAR2(40);
	WS_TITLE 			CLOB;
	WS_GOTOCOUNTER		NUMBER;
	
	WS_STEP             NUMBER;
	WS_STEPPER          NUMBER := 0;
	WS_LARGURA          VARCHAR2(60) := '0';
	
	
	WS_LINHA            NUMBER := 0;
	WS_LINHA_COL        NUMBER := 0;
	WS_FIXED            NUMBER;
	WS_FIX              VARCHAR2(80);
	WS_CT_TOP           NUMBER := 0;
	WS_TOP              NUMBER := 0;
	WS_TMP_CHECK        VARCHAR2(300);
	WS_CHECK            VARCHAR2(300);
	WS_ROW              NUMBER;
	WS_PIVOT            VARCHAR2(300);
	WS_DISTINCTMED      NUMBER := 0;
	WS_CAB_CROSS        VARCHAR2(4000);
    RET_COLGRP          VARCHAR2(2000);
	RET_COLTOT          VARCHAR2(2000);
	WS_TEMP_VALOR       NUMBER := 0;
	WS_TEMP_VALOR2      NUMBER := 0;
    WS_TOTAL_LINHA      NUMBER := 0;
	WS_ACUMULADA_LINHA  NUMBER := 0;
	WS_LINHA_ACUMULADA  VARCHAR2(10);
	WS_TOTAL_ACUMULADO  VARCHAR2(10);
	
	WS_LIMITE_I         VARCHAR2(10);
	WS_LIMITE_F         VARCHAR2(10);
	WS_ISOLADO          VARCHAR2(60);
	WS_REPEAT           VARCHAR2(60) := 'show';
	WS_SUBQUERY         VARCHAR2(600);
	WS_PROPAGATION      VARCHAR2(400);
	WS_ORDER            VARCHAR2(90);
	WS_ALINHAMENTO      VARCHAR2(80);
	WS_NM_VAR_AL        VARCHAR2(400);
	WS_CD_COLUNA        VARCHAR2(400);
	WS_TEXTO_AL         VARCHAR2(4000);
	WS_ARRAY_ATUAL      DBMS_SQL.VARCHAR2_TABLE;
	WS_CLASS_ATUAL      DBMS_SQL.VARCHAR2_TABLE;
	WS_ARRAY_ANTERIOR   DBMS_SQL.VARCHAR2_TABLE;
	WS_COUNT            NUMBER := 0;
	DIMENSAO_SOMA       NUMBER := 1;
	WS_BLINK_LINHA      VARCHAR2(4000) := 'N/A';
	WS_CHAVE            VARCHAR2(100);
	WS_TEMPO            DATE;
	WS_TPT              VARCHAR2(400);
	WS_EXCEL            CLOB;
	WS_SAIDA            VARCHAR2(10) := 'S';
	WS_PIVOT_COLUNA     VARCHAR2(4000);
	WS_SHOW_ACTIVE      VARCHAR2(2);
	
	WS_FULL             VARCHAR2(10);
	WS_SHOW_ONLY        VARCHAR2(10);
	WS_COUNT_VISIVEL    NUMBER;
	WS_HINT             VARCHAR2(2000);
	WS_SEMACESSO        EXCEPTION;
	
	
	WS_BORDA            VARCHAR2(60);
    WS_NULL             VARCHAR2(1) := NULL;
    WS_CONTEUDO_ANT     VARCHAR2(4000);
    WS_CALCULADA        VARCHAR2(800);
    WS_CALCULADA_N      VARCHAR2(200);
    WS_CALCULADA_M      VARCHAR2(200);
    WS_AMOSTRA          NUMBER := 0;
	
	WS_BINDS            VARCHAR2(3000);
	WS_ORDEM_ARROW      VARCHAR2(100);
	WS_DIFERENCA        VARCHAR2(4000);
	WS_COLUNAS_VALOR    NUMBER;
	
	WS_HTML             VARCHAR2(2000);
	WS_CLASSE           VARCHAR2(400);
	WS_COD_COLUNA       VARCHAR2(2000);
	REC_TAB             DBMS_SQL.DESC_TAB;
    WS_COD              VARCHAR2(80);
	
	WS_LINHA_CALCULADA  VARCHAR2(20);
	WS_ALINHAMENTO_TIT  VARCHAR2(80);
	WS_USUARIO          VARCHAR2(80);
	WS_LOGIN            EXCEPTION;
	WS_COOKIE           OWA_COOKIE.COOKIE;
	WS_CUT              VARCHAR2(120);
	NAME_ARR OWA_COOKIE.VC_ARR;
    VALS_ARR OWA_COOKIE.VC_ARR;
	VALS_RET INTEGER;
	WS_ADMIN            VARCHAR2(4);
	WS_TEMPO_QUERY   NUMBER := 0;
	WS_TEMPO_AVG     NUMBER := 0;
	WS_QUERY_HINT    VARCHAR2(80);

BEGIN

    IF FUN.CHECK_SYS <> 'OPEN' THEN
		RAISE WS_ACESSO;
	END IF;
	
	IF NVL(FUN.RET_VAR('XE'), 'N') = 'S' THEN
		WS_USUARIO := USER;
	ELSE
		BEGIN
			WS_COOKIE := OWA_COOKIE.GET('SESSION');
			WS_CUT    := WS_COOKIE.VALS(1);

			IF NVL(FUN.GETSESSAO(WS_CUT), 'DWU') = 'DWU' THEN
				RAISE WS_LOGIN;
			END IF;
		EXCEPTION WHEN OTHERS THEN
			RAISE WS_LOGIN;
		END;
		
		WS_USUARIO := GBL.GETUSUARIO;
	END IF;
	
	WS_ADMIN   := GBL.GETNIVEL;


	IF  NOT FUN.CHECK_NETWALL(WS_USUARIO)  THEN
		    INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, 'USU&Aacute;RIO SEM ACESSO, BLOQUEIO DE NETWALL', WS_USUARIO, 'EVENTO');
            COMMIT;
        RAISE WS_SEMACESSO;
    END IF;
	
	IF PRM_COMANDO = 'MOUNT' THEN
		RAISE WS_MOUNT;
    END IF;

EXCEPTION
    WHEN WS_LOGIN THEN
	    HTP.P('<html id="html" oncontextmenu="donut(event); return false;">');

				HTP.P('<head>');
					HTP.P('<link rel="manifest" href="dwu.fcl.downloadOpen?arquivo=manifest">');
					HTP.P('<meta http-equiv="cache-control" content="max-age=0" />');
					HTP.P('<meta http-equiv="cache-control" content="no-cache" />');
					HTP.P('<meta name="apple-mobile-web-app-capable" content="black-translucent" />');
					HTP.P('<meta http-equiv="Pragma" content="no-cache"/>');
					HTP.P('<meta name="mobile-web-app-capable" content="yes" />');
					
					
					HTP.P('<link rel="favicon" type="image/png" href="'||FUN.R_GIF('upquery-icon','PNG')||'" />');
					HTP.P('<link rel="icon" type="image/png" href="'||FUN.R_GIF('ipad','PNG')||'" />');
					HTP.P('<link rel="shortcut icon apple-touch-icon" href="'||FUN.R_GIF('ipad','PNG')||'" />');
					HTP.P('<link rel="apple-touch-icon" href="'||FUN.R_GIF('ipad','PNG')||'" />');
					HTP.P('<link rel="apple-touch-startup-image" href="'||FUN.R_GIF('logo','PNG')||'">');
					HTP.P('<meta name="theme-color" content="#9a9a9a"/>');
					HTP.P('<meta name="apple-mobile-web-app-status-bar-style" content="black">');
					HTP.P('<meta name="viewport" content="width=device-width; initial-scale=1; viewport-fit=cover; user-scalable=0">');
					
					HTP.P('<link rel="stylesheet" href="dwu.fcl.downloadOpen?arquivo=tema">');
					HTP.P('<script src="dwu.fcl.downloadOpen?arquivo=js"></script>');
				    HTP.P('<link rel="stylesheet" href="dwu.fcl.downloadOpen?arquivo=css">');

					HTP.P('<link href="https://fonts.googleapis.com/css?family=Montserrat" rel="stylesheet" type="text/css">');
					HTP.P('<link href="https://fonts.googleapis.com/css?family=Quicksand" rel="stylesheet" type="text/css">');
					HTP.P('<link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro&display=swap" rel="stylesheet" type="text/css">'); 

						FCL.KEYWORDS;

				HTP.P('</head>');
				HTP.P('<body>');
				    
					
                    

					FUN.SETSESSAO(PRM_DATA => SYSDATE);
	                FCL.LOGINSCREEN;
				HTP.P('</body>');
			HTP.P('</html>');
        

		WHEN WS_NOVA_SESSAO THEN
		    FCL.LOGINSCREEN;
        WHEN WS_MOUNT THEN
	        
			    
			
				

				
            	
				FUN.SETSESSAO(PRM_DATA => SYSDATE);
			    FCL.INICIAR;
			
        WHEN WS_CLOSE_HTML THEN
	        FCL.POSICIONA_OBJETO('newquery','DWU','DEFAULT','DEFAULT');
	    WHEN WS_PARSEERR   THEN
	    IF WS_VAZIO THEN
            INSERT INTO LOG_EVENTOS VALUES(SYSDATE, PRM_MICRO_VISAO||'/'||WS_COLUNA||'/'||TRIM(WS_PARAMETROS)||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR, WS_USUARIO, 'VAZIO', 'NODATA', '01');
	        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, 'VAZIO: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - VAZIO', WS_USUARIO, 'ERRO');
            COMMIT;
		ELSE
            INSERT INTO LOG_EVENTOS VALUES(SYSDATE, PRM_MICRO_VISAO||'/'||WS_COLUNA||'/'||TRIM(WS_PARAMETROS)||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR, WS_USUARIO, 'NOVAZIO', 'PARSE', '01');
		END IF;
	    COMMIT;
		HTP.P('<span style="margin: 10px; display: block; text-align: center; font-weight: bold; font-family: var(--fonte-primaria);">'||FUN.SUBPAR(FUN.GETPROP(PRM_OBJID,'ERR_SD', PRM_TIPO => 'CONSULTA'), PRM_SCREEN)||'</span>');
		IF WS_ADMIN = 'A' THEN
		
		    WS_QUERYOC := '';
		
		    HTP.P('<textarea class="errorquery">');
				WS_COUNTER := 0;
				
					LOOP
						WS_COUNTER := WS_COUNTER + 1;
						IF  WS_COUNTER > WS_QUERY_MONTADA.COUNT THEN
							EXIT;
						END IF;
						WS_QUERYOC := WS_QUERYOC||WS_QUERY_MONTADA(WS_COUNTER);
					END LOOP;
					FCL.REPLACE_BINDS(WS_QUERYOC, WS_BINDS);
				
				
				
		    HTP.P('</textarea>');
			
		END IF;
		HTP.P('</span></div>');
	WHEN WS_INVALIDO   THEN
        INSERT INTO LOG_EVENTOS VALUES(SYSDATE, PRM_MICRO_VISAO||'/'||WS_COLUNA||'/'||TRIM(WS_PARAMETROS)||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR, WS_USUARIO, 'INVALIDO', 'E-ACC', '01');
	    INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, 'INV&Aacute;LIDO: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - INVALIDO', WS_USUARIO, 'ERRO');
        COMMIT;
	    FCL.NEGADO(FUN.LANG('Parametros Invalidos'));
	WHEN WS_ACESSO	     THEN
	    HTP.P('<!doctype html public "-//W3C//DTD html 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">');
		HTP.P('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">');
			HTP.P('<body>');
				HTP.P('<div style="font-weight: bold; font-size: 16px; color: #cc0000; font-family: tahoma; position: absolute; top: calc(50% - 10px); left: calc(50% - 102px);">'||FUN.LANG('SISTEMA INDISPON&Iacute;VEL!')||'</div>');
			HTP.P('</body>');
		HTP.P('</html>');
	WHEN WS_SEMQUERY     THEN
        INSERT INTO LOG_EVENTOS VALUES(SYSDATE, PRM_MICRO_VISAO||'/'||WS_COLUNA||'/'||TRIM(WS_PARAMETROS)||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR, WS_USUARIO, 'SEMQUERY', 'SEMQUERY', '01');
	    INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SEMQUERY', WS_USUARIO, 'ERRO');
        COMMIT;
	    FCL.NEGADO('['||PRM_MICRO_VISAO||']-['||PRM_OBJID||']-'||FUN.LANG('Relat&oacute;rio Sem Query'));
	WHEN WS_NODATA	     THEN
		INSERT INTO LOG_EVENTOS VALUES(SYSDATE, PRM_MICRO_VISAO||'/'||WS_COLUNA||'/'||TRIM(WS_PARAMETROS)||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR, WS_USUARIO, 'NODATA', 'NODATA', '01');
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - NODATA', WS_USUARIO, 'ERRO');
        COMMIT;
		
		IF LENGTH(FUN.GETPROP(PRM_OBJID, 'BORDA_COR', PRM_TIPO => 'CONSULTA')) > 0 THEN
			WS_BORDA := 'border: 1px solid '||TRIM(FUN.GETPROP(PRM_OBJID, 'BORDA_COR', PRM_TIPO => 'CONSULTA'))||';';
		END IF;

		HTP.P('<div id="'||WS_OBJID||'" onmousedown="'||WS_PROPAGATION||'" class="dragme front" data-visao="'||PRM_MICRO_VISAO||'" data-drill="'||PRM_DRILL||'" style="'||WS_POSICAO||' background-color: '||FUN.GETPROP(PRM_OBJID, 'FUNDO_VALOR', PRM_TIPO => 'CONSULTA')||'; '||WS_BORDA||'">');
        
		HTP.P('<span class="turn">');

			IF TO_NUMBER(FUN.RET_VAR('ORACLE_VERSION')) > 10 THEN
				SELECT COUNT(*) INTO WS_COUNTER FROM TABLE(FUN.VPIPE_PAR(PRM_COLUNA));
				IF WS_COUNTER = 0 AND NVL(TRIM(PRM_COLUP), 'null') = 'null' THEN
					HTP.P('<span class="arrowturn">&#x21B2;</span>');
					IF LENGTH(TRIM(FUN.SHOW_FILTROS(TRIM(WS_PARAMETROS), WS_CURSOR, '', PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN))) > 3 THEN
						HTP.P('<span class="filtros">F</span>');
					END IF;
				END IF;
			END IF;

			IF LENGTH(TRIM(FUN.SHOW_FILTROS(TRIM(WS_PARAMETROS), WS_CURSOR, '', PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN))) > 3 THEN
				IF WS_COUNTER <> 0 OR NVL(TRIM(PRM_COLUP), 'null') <> 'null' THEN
					HTP.P('<span class="filtros">F</span>');
				END IF;
			END IF;
			
			IF LENGTH(TRIM(FUN.SHOW_DESTAQUES(TRIM(WS_PARAMETROS), WS_CURSOR, '', PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN))) > 3 THEN
				HTP.P('<span class="destaques">');
					HTP.P('<svg style="height: calc(100% - 10px); width: calc(100% - 10px); margin: 5px; fill: #333; pointer-events: none;" enable-background="new -1.23 -8.789 141.732 141.732" height="141.732px" id="Livello_1" version="1.1" viewBox="-1.23 -8.789 141.732 141.732" width="141.732px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g id="Livello_100"><path d="M139.273,49.088c0-3.284-2.75-5.949-6.146-5.949c-0.219,0-0.434,0.012-0.646,0.031l-42.445-1.001l-14.5-37.854   C74.805,1.824,72.443,0,69.637,0c-2.809,0-5.168,1.824-5.902,4.315L49.232,42.169L6.789,43.17c-0.213-0.021-0.43-0.031-0.646-0.031   C2.75,43.136,0,45.802,0,49.088c0,2.1,1.121,3.938,2.812,4.997l33.807,23.9l-12.063,37.494c-0.438,0.813-0.688,1.741-0.688,2.723   c0,3.287,2.75,5.952,6.146,5.952c1.438,0,2.766-0.484,3.812-1.29l35.814-22.737l35.812,22.737c1.049,0.806,2.371,1.29,3.812,1.29   c3.393,0,6.143-2.665,6.143-5.952c0-0.979-0.25-1.906-0.688-2.723l-12.062-37.494l33.806-23.9   C138.15,53.024,139.273,51.185,139.273,49.088"/></g><g id="Livello_1_1_"/></svg>');
				HTP.P('</span>');
			END IF;
			
		HTP.P('</span>');

		HTP.P('<ul id="'||WS_OBJID||'-filterlist" style="display: none;" >');
			HTP.P(FUN.SHOW_FILTROS(TRIM(WS_PARAMETROS), WS_CURSOR, WS_ISOLADO, PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN));
		HTP.P('</ul>');
		
		HTP.P('<ul id="'||WS_OBJID||'-destaquelist" style="display: none;" >');
			HTP.P(FUN.SHOW_DESTAQUES(TRIM(WS_PARAMETROS), WS_CURSOR, WS_ISOLADO, PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN));
		HTP.P('</ul>');
		
		
		IF INSTR(WS_OBJID, 'trl') = 0 THEN
	        HTP.P('<span id="'||WS_OBJID||'sync" class="sync"><img src="dwu.fcl.download?arquivo=sinchronize.png" /></span>');
        END IF;
	    
		IF WS_ADMIN = 'A' THEN
	    	 HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJID||'more">');
				HTP.P(FUN.SHOWTAG(PRM_OBJID, 'atrib', PRM_SCREEN));
				HTP.P('<span class="preferencias" data-visao="'||PRM_MICRO_VISAO||'" data-drill="'||PRM_DRILL||'" title="'||FUN.LANG('Propriedades')||'"></span>');
				HTP.P(FUN.SHOWTAG(PRM_OBJID, 'filter', PRM_MICRO_VISAO));
				HTP.P('<span class="sigma" title="'||FUN.LANG('Linha calculada')||'"></span>');
				HTP.P('<span class="lightbulb" title="Drill"></span>');
	   			HTP.P(FUN.SHOWTAG(WS_OBJID||'c', 'excel'));
				HTP.P('<span class="data_table" title="'||FUN.LANG('Alterar Consulta')||'"></span>');
				HTP.P(FUN.SHOWTAG('', 'star'));
				FCL.BUTTON_LIXO('dl_obj', PRM_OBJETO=> PRM_OBJID, PRM_TAG => 'span');
			HTP.P('</span>');

			IF PRM_DRILL = 'Y' THEN
			    HTP.P('<a class="fechar" id="'||WS_OBJID||'fechar" title="'||FUN.LANG('Fechar')||'"></a>');
			END IF;

	    ELSE
	        IF PRM_DRILL = 'Y' THEN
	   		    HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJID||'more" style="max-width: 106px; max-height: 26px;">');
	   		ELSE
	   		    HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJID||'more" style="right: 0; max-width: 106px; max-height: 26px;">');
	   		END IF;
			    HTP.P('<span class="lightbulb" title="Drill"></span>');
				
			    HTP.P(FUN.SHOWTAG(WS_OBJID||'c', 'excel'));
				HTP.P(FUN.SHOWTAG('', 'star'));
			HTP.P('</span>');
			IF PRM_DRILL = 'Y' THEN
			    HTP.P('<a class="fechar" id="'||WS_OBJID||'fechar" title="'||FUN.LANG('Fechar')||'"></a>');
			END IF;
	   END IF;

	   HTP.P('<div class="wd_move" style="text-align: '||FUN.GETPROP(PRM_OBJID,'ALIGN_TIT', PRM_TIPO => 'CONSULTA')||'; height: 16px; font-weight: bold; margin: 6px 28px; background-color: '||FUN.GETPROP(PRM_OBJID,'FUNDO_TIT', PRM_TIPO => 'CONSULTA')||'; color: '||FUN.GETPROP(PRM_OBJID,'FONTE_TIT', PRM_TIPO => 'CONSULTA')||'">'||WS_NOME||'</div>');

	   IF WS_ADMIN = 'A' THEN
		   HTP.P('<span class="errorquery">'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - others</span>');
	   END IF;

	   HTP.P('</div>');
	   HTP.P('</div>');
	   HTP.P('<div></div>');
		
	WHEN WS_SEMPERMISSAO THEN
	   FCL.NEGADO(PRM_MICRO_VISAO||' - '||FUN.LANG('Sem Permiss&atilde;o Para Este Filtro')||'.');
	WHEN WS_SEMACESSO THEN

		AUX.CHECK_LIST(WS_USUARIO, 'iniciar');
	
	WHEN OTHERS	     THEN

		HTP.P(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
		INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - UPQUERY', WS_USUARIO, 'ERRO');

END MAIN;

PROCEDURE DIRECT (  PRM_USUARIO  VARCHAR2 DEFAULT NULL,
					PRM_PASSWORD VARCHAR2 DEFAULT NULL ) AS 

	WS_SHOW VARCHAR2(10);

BEGIN


	SELECT SHOW_ONLY INTO WS_SHOW FROM USUARIOS WHERE UPPER(USU_NOME) = UPPER(PRM_USUARIO);

	IF WS_SHOW = 'S' THEN
		FCL.LOGIN (PRM_USUARIO, PRM_PASSWORD, PRM_PRAZO => 99999);
		FCL.INICIAR;
	ELSE
		HTP.P('Sem permissao!');
	END IF;
EXCEPTION WHEN OTHERS THEN
	HTP.P(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END DIRECT;

PROCEDURE TAB_CROSS (
			PRM_PARAMETROS	 CHAR DEFAULT '1|1',
			PRM_MICRO_VISAO  CHAR DEFAULT NULL,
			PRM_COLUNA	     CHAR DEFAULT NULL,
			PRM_AGRUPADOR	 CHAR DEFAULT NULL,
			PRM_RP		     CHAR DEFAULT 'ROLL',
			PRM_COLUP	     CHAR DEFAULT NULL,
			PRM_COMANDO	     CHAR DEFAULT 'MOUNT',
			PRM_MODE	     CHAR DEFAULT 'NO',
			PRM_OBJID	     CHAR DEFAULT NULL,
			PRM_SCREEN	     CHAR DEFAULT 'DEFAULT',
			PRM_POSX	     CHAR DEFAULT NULL,
			PRM_POSY	     CHAR DEFAULT NULL,
			PRM_CCOUNT	     CHAR DEFAULT '0',
			PRM_DRILL	     CHAR DEFAULT 'N',
			PRM_ORDEM	     CHAR DEFAULT '0',
			PRM_ZINDEX	     CHAR DEFAULT 'auto',
            PRM_TRACK        VARCHAR2 DEFAULT NULL,
            PRM_OBJETON      VARCHAR2 DEFAULT NULL,
			PRM_DASHBOARD    VARCHAR2 DEFAULT 'false' ) AS

	CURSOR CRS_MICRO_VISAO IS
			SELECT	RTRIM(CD_GRUPO_FUNCAO) AS CD_GRUPO_FUNCAO
			FROM 	MICRO_VISAO WHERE NM_MICRO_VISAO = PRM_MICRO_VISAO;

	WS_MICRO_VISAO CRS_MICRO_VISAO%ROWTYPE;

	CURSOR CRS_XGOTO(PRM_USUARIO VARCHAR2) IS
			SELECT	RTRIM(CD_OBJETO_GO) AS CD_OBJETO_GO
			FROM 	GOTO_OBJETO WHERE CD_OBJETO = PRM_OBJID AND
			        CD_OBJETO_GO NOT IN ( SELECT CD_OBJETO FROM OBJECT_RESTRICTION WHERE USUARIO = PRM_USUARIO )
			ORDER BY CD_OBJETO_GO;

	WS_XGOTO CRS_XGOTO%ROWTYPE;

	TYPE WS_TMCOLUNAS IS TABLE OF MICRO_COLUNA%ROWTYPE
			    		INDEX BY PLS_INTEGER;

	TYPE GENERIC_CURSOR IS REF CURSOR;

	CRS_SAIDA GENERIC_CURSOR;

	CURSOR NC_COLUNAS IS SELECT * FROM MICRO_COLUNA WHERE CD_MICRO_VISAO = PRM_MICRO_VISAO;

	RET_COLUNA			VARCHAR2(2000);
	RET_MCOL			WS_TMCOLUNAS;

	WS_NCOLUMNS			DBMS_SQL.VARCHAR2_TABLE;
	WS_COLUNA_ANT		DBMS_SQL.VARCHAR2_TABLE;
	WS_PVCOLUMNS		DBMS_SQL.VARCHAR2_TABLE;
	WS_MFILTRO			DBMS_SQL.VARCHAR2_TABLE;
	WS_VCOL				DBMS_SQL.VARCHAR2_TABLE;
	WS_VCON				DBMS_SQL.VARCHAR2_TABLE;

	WS_DRILL			VARCHAR2(40);
	WS_OBJID			VARCHAR2(120);
	WS_ZEBRADO			VARCHAR2(20);
	WS_ZEBRADO_D		VARCHAR2(40);
	WS_QUERYOC			CLOB;
	WS_PIPE				CHAR(1);

	WS_POSX				VARCHAR(5);
	WS_POSY				VARCHAR(5);

	RET_COLUP			LONG;
	WS_LQUERY			NUMBER;
	WS_COUNTERID		NUMBER := 0;
	WS_COUNTER			NUMBER := 1;
	WS_CCOLUNA			NUMBER := 1;
	WS_XCOLUNA			NUMBER := 0;
	WS_CHCOR			NUMBER := 0;
	WS_BINDN			NUMBER := 0;
	WS_SCOL				NUMBER := 0;
	WS_CSPAN			NUMBER := 0;
	WS_XCOUNT			NUMBER := 0;
	WS_CTNULL			NUMBER := 0;
	WS_CTCOL			NUMBER := 0;

	WS_TEXTO			LONG;
	WS_TEXTOT			LONG;
	WS_NM_VAR			LONG;
	WS_CONTENT_ANT		LONG;
	WS_CONTENT			LONG;
	WS_COLUP			LONG;
	WS_COLUNA			LONG;
	WS_AGRUPADOR		LONG;
	WS_RP				LONG;
	WS_XATALHO			LONG;
	WS_ATALHO			LONG;
	WS_PARAMETROS		LONG;
	WS_ORDEM			VARCHAR2(400);
	WS_ORDEM_QUERY		VARCHAR2(400);
	WS_COUNTOR          NUMBER;

	WS_ACESSO			EXCEPTION;
	WS_SEMQUERY			EXCEPTION;
	WS_SEMPERMISSAO		EXCEPTION;
	WS_PCURSOR			INTEGER;
	WS_CURSOR			INTEGER;
	WS_LINHAS			INTEGER;
	WS_QUERY_MONTADA	DBMS_SQL.VARCHAR2A;
	WS_QUERY_COUNT      DBMS_SQL.VARCHAR2A;
	WS_QUERY_PIVOT		LONG;
	WS_SQL				LONG;
	WS_SQL_PIVOT		LONG;
	
	
	WS_TITULO			VARCHAR2(150);
	
	WS_MODE				VARCHAR2(30);
	WS_IDCOL			VARCHAR2(120);
	WS_CLEARDRILL		VARCHAR2(120);
	WS_FIRSTID			CHAR(1);

	WS_VAZIO			BOOLEAN := TRUE;
	WS_NODATA       	EXCEPTION;
	WS_INVALIDO			EXCEPTION;
	
	WS_CLOSE_HTML		EXCEPTION;
	WS_MOUNT			EXCEPTION;
	WS_PARSEERR			EXCEPTION;
	WS_AGRUPADOR_MAX NUMBER;

	WS_POSICAO			VARCHAR2(2000) := ' ';
	WS_DRILL_ATALHO		VARCHAR2(3000);
	WS_CTEMP			VARCHAR2(40);
	WS_TMP_JUMP			VARCHAR2(300);
	WS_JUMP				VARCHAR2(600);
	WS_POSIX			VARCHAR2(80);
	WS_POSIY			VARCHAR2(80);
	WS_SEM				VARCHAR2(40);
	WS_TITLE 			CLOB;
	WS_GOTOCOUNTER		NUMBER;
	
	WS_STEP             NUMBER;
	WS_STEPPER          NUMBER := 0;
	WS_LARGURA          VARCHAR2(60);
	
	
	WS_LINHA            NUMBER := 0;
	WS_FIXED            VARCHAR2(40);
	WS_CT_TOP           NUMBER := 0;
	WS_TOP              NUMBER := 0;
	WS_TMP_CHECK        VARCHAR2(300);
	WS_CHECK            VARCHAR2(300);
	WS_ROW              NUMBER;
	WS_PIVOT            VARCHAR2(300);
	WS_DISTINCTMED      NUMBER := 0;
	WS_CAB_CROSS        VARCHAR2(4000);
	WS_REFCOL           VARCHAR2(4000);
	WS_LIMITE_COL       NUMBER;
	WS_LINHA_CALC       NUMBER;
	WS_TEMP_VALOR NUMBER := 0;
    WS_TOTAL_LINHA NUMBER := 0;
	WS_ACUMULADA_LINHA NUMBER := 0;
	RET_COLGRP          VARCHAR2(2000);
	WS_LINHA_ACUMULADA VARCHAR2(10);
	WS_TOTAL_ACUMULADO VARCHAR2(10);
	WS_LIMITE_I VARCHAR2(10);
	WS_LIMITE_F VARCHAR2(10);
	
	WS_PROPAGATION VARCHAR2(30);
	WS_ORDER         VARCHAR2(60);
	WS_BLINK_LINHA      VARCHAR2(4000) := 'N/A';
    WS_TPT              VARCHAR2(400);
	WS_COUNT            NUMBER;
	WS_BORDA            VARCHAR2(60);
    WS_NULL             VARCHAR2(1) := NULL;
    WS_NOME             VARCHAR2(400);
	WS_HTML             VARCHAR2(4000);
	WS_CLASSE           VARCHAR2(400);
	WS_LIGACAO          VARCHAR2(200);
	WS_USUARIO          VARCHAR2(80);
	WS_ADMIN            VARCHAR2(4);
BEGIN

    WS_USUARIO := GBL.GETUSUARIO;
	WS_ADMIN   := GBL.GETNIVEL;

    IF PRM_DASHBOARD <> 'false' THEN
	    WS_PROPAGATION := 'event.stopPropagation();';
	ELSE
	    WS_PROPAGATION := '';
	END IF;

	IF(INSTR(PRM_POSX, '-') = 1) THEN
		WS_POSIX := '5px';
	ELSE
		WS_POSIX := PRM_POSX;
	END IF;

	IF(INSTR(PRM_POSY, '-') = 1) THEN
		WS_POSIY := '65px';
	ELSE
		WS_POSIY := PRM_POSY;
	END IF;

	

	IF PRM_DASHBOARD <> 'false' THEN
	    WS_ORDER := 'order: '||WS_POSIX||';';
	ELSE
		WS_ORDER := 'left: '||WS_POSIX||';';
	END IF;

	IF  NVL(PRM_POSX,'NOLOC') <> 'NOLOC' THEN
	    WS_POSICAO := ' position: absolute; top:'||WS_POSIY||'; '||WS_ORDER||' ';
	ELSE
	    IF(PRM_DRILL = 'O') THEN
		    WS_POSICAO := ' position: absolute; top: 8px; left: 8px; ';
		ELSE
	        WS_POSICAO := ' position: absolute; top: 110px; left: 7px; ';
		END IF;
	END IF;

	WS_COLUP     := PRM_COLUP;
	WS_COLUNA    := PRM_COLUNA;
	WS_AGRUPADOR := FUN.CONV_TEMPLATE(PRM_MICRO_VISAO, PRM_AGRUPADOR);
	WS_MODE      := PRM_MODE;
	WS_RP	     := PRM_RP;
	WS_MODE	     := 'ED';

	OPEN CRS_MICRO_VISAO;
	FETCH CRS_MICRO_VISAO INTO WS_MICRO_VISAO;
	CLOSE CRS_MICRO_VISAO;

	WS_TEXTO := PRM_PARAMETROS;

    WS_PARAMETROS := PRM_PARAMETROS;

	OPEN NC_COLUNAS;
	LOOP
	    FETCH NC_COLUNAS BULK COLLECT INTO RET_MCOL LIMIT 400;
	    EXIT WHEN NC_COLUNAS%NOTFOUND;
	END LOOP;
	CLOSE NC_COLUNAS;

	WS_COUNTER := 0;
	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > RET_MCOL.COUNT THEN
	    	EXIT;
	    END IF;
	    IF RTRIM(RET_MCOL(WS_COUNTER).ST_AGRUPADOR) <> 'SEM' AND FUN.SETEM(WS_AGRUPADOR,RTRIM(RET_MCOL(WS_COUNTER).CD_COLUNA)) THEN
		WS_SCOL := WS_SCOL + 1;
	    END IF;
	END LOOP;

	IF NVL(PRM_OBJID,'%$%') <> '%$%' AND PRM_OBJID <> 'newquery' THEN
	   WS_RP := FUN.GETPROP(PRM_OBJID,'TP_GRUPO');
	END IF;

	WS_SEM := 1;

	IF SUBSTR(WS_PARAMETROS,LENGTH(WS_PARAMETROS),1)='|' THEN
       WS_PARAMETROS := SUBSTR(WS_PARAMETROS,1,LENGTH(WS_PARAMETROS)-1);
    END IF;

	WS_ORDEM := '';
	WS_ORDEM_QUERY := '';
	WS_COUNTOR := 0;
	SELECT COUNT(*) INTO WS_COUNTOR FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJID AND CD_PROP = 'ORDEM' AND OWNER = WS_USUARIO;
	IF WS_COUNTOR = 1 THEN
	    SELECT UPPER(PROPRIEDADE) INTO WS_ORDEM_QUERY FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJID AND CD_PROP = 'ORDEM' AND OWNER = WS_USUARIO;
	    WS_ORDEM := WS_ORDEM_QUERY;
	ELSE
	    SELECT COUNT(*) INTO WS_COUNTOR FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJID AND CD_PROP = 'ORDEM' AND OWNER = 'DWU';
	    IF WS_COUNTOR = 1 THEN
	        SELECT UPPER(PROPRIEDADE) INTO WS_ORDEM_QUERY FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJID AND CD_PROP = 'ORDEM' AND OWNER = 'DWU';
	    END IF;
	END IF;

	WS_SQL := CORE.MONTA_QUERY_DIRECT(PRM_MICRO_VISAO, WS_COLUNA, WS_PARAMETROS, WS_RP, WS_COLUP, WS_QUERY_PIVOT, WS_QUERY_MONTADA, WS_LQUERY, WS_NCOLUMNS, WS_PVCOLUMNS, WS_AGRUPADOR, WS_MFILTRO, PRM_OBJID, WS_ORDEM_QUERY, PRM_SCREEN => PRM_SCREEN, PRM_CROSS => 'S', PRM_CAB_CROSS => WS_CAB_CROSS);

    INSERT INTO LOG_EVENTOS VALUES(SYSDATE, PRM_MICRO_VISAO||'/'||WS_COLUNA||'/'||TRIM(WS_PARAMETROS)||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR, WS_USUARIO, 'ACESSO', 'ACESSO', '01');

	WS_QUERYOC := '';
	WS_COUNTER := 0;
	WS_GOTOCOUNTER := 0;

	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > WS_QUERY_MONTADA.COUNT THEN
	    	EXIT;
	    END IF;
	    WS_QUERYOC := WS_QUERYOC||WS_QUERY_MONTADA(WS_COUNTER);
	END LOOP;
	
	IF WS_SQL = 'Sem Query' THEN
	   RAISE WS_SEMQUERY;
	END IF;

	WS_SQL_PIVOT := WS_QUERY_PIVOT;

	OPEN CRS_XGOTO(WS_USUARIO);
	LOOP
	    FETCH CRS_XGOTO INTO WS_XGOTO;
	    EXIT WHEN CRS_XGOTO%NOTFOUND;
		WS_GOTOCOUNTER := WS_GOTOCOUNTER+1;
	END LOOP;
	CLOSE CRS_XGOTO;

	IF(WS_GOTOCOUNTER > 0) THEN
	        WS_TMP_JUMP := '';
	END IF;

	IF LENGTH(FUN.GETPROP(PRM_OBJID, 'BORDA_COR')) > 0 THEN
		IF PRM_DRILL <> 'Y' THEN
		    WS_BORDA := 'border: 1px solid '||TRIM(FUN.GETPROP(PRM_OBJID, 'BORDA_COR'))||';';
		ELSE
		    WS_BORDA := 'height: auto; border: 1px solid '||TRIM(FUN.GETPROP(PRM_OBJID, 'BORDA_COR'))||';';
		END IF;
	END IF;
	
	WS_OBJID := PRM_OBJID;
	
	IF PRM_DRILL = 'Y' THEN
	    WS_CLASSE := 'dragme front drill cross';
		WS_OBJID := WS_OBJID||'trl';
	ELSE
	    WS_CLASSE := 'dragme front cross';
	    WS_OBJID := WS_OBJID;
	END IF;

	IF PRM_DRILL <> 'Y' THEN
	    WS_HTML := 'data-refresh="12000" data-swipe="" ontouchstart="swipeStart('''||WS_OBJID||''', event); selectmouse(event);" ontouchmove="swipe('''||WS_OBJID||''', event);" ontouchend="swipe('''||WS_OBJID||''', event);"';
	END IF;
	
	HTP.P('<div id="'||WS_OBJID||'" data-drillt="'||FUN.GETPROP(PRM_OBJID,'DRILLT')||'" data-full="'||FUN.GETPROP(PRM_OBJID,'FULL')||'" data-cell="'||WS_ORDEM||'" data-track="" data-left="'||WS_POSIX||'" data-top="'||WS_POSIY||'" data-visao="'||PRM_MICRO_VISAO||'" data-drill="'||PRM_DRILL||'" onmousedown="'||WS_PROPAGATION||'" class="'||WS_CLASSE||'" style="background-color: '||FUN.GETPROP(PRM_OBJID, 'FUNDO_VALOR')||'; '||WS_POSICAO||' max-width: calc(100% - '||FUN.GETPROP(PRM_OBJID,'DASH_MARGIN_LEFT', PRM_SCREEN)||' - '||FUN.GETPROP(PRM_OBJID,'DASH_MARGIN_RIGHT', PRM_SCREEN)||'); '||WS_BORDA||'" '||WS_HTML||'>');
    WS_HTML   := '';
	WS_CLASSE := '';
	

	IF FUN.GETPROP(PRM_OBJID,'NO_RADIUS') <> 'N' THEN
        HTP.P('<style>div#'||WS_OBJID||' table tr td, div#'||WS_OBJID||' table tr th, div#'||WS_OBJID||'fixed, div#'||WS_OBJID||'fixed { font-size: '||FUN.GETPROP(PRM_OBJID,'FONT_SIZE')||'; } div#'||WS_OBJID||', span#'||WS_OBJID||'_ds { border-radius: 0; } div#'||WS_OBJID||' span#'||WS_OBJID||'more { border-radius: 0 0 6px 0; } /*a#'||WS_OBJID||'fechar { border-radius: 0 0 0 6px; }*/</style>');
	ELSE
	    HTP.P('<style>div#'||WS_OBJID||' table td td, div#'||WS_OBJID||' table tr th, div#'||WS_OBJID||'fixed, div#'||WS_OBJID||'fixed { font-size: '||FUN.GETPROP(PRM_OBJID,'FONT_SIZE')||'; }</style>');
	END IF;


	HTP.P('<style>div#'||WS_OBJID||'fixed span, div.dragme.cross div.header table tbody tr:first-child, div.dragme.cross div.header table tbody tr:first-child td { background: '||FUN.GETPROP(PRM_OBJID, 'FUNDO_CABECALHO')||'; color: '||FUN.GETPROP(PRM_OBJID, 'FONTE_CABECALHO')||'; }');
	    HTP.P('table#'||WS_OBJID||'c tr.total, div#'||WS_OBJID||'fixed li.total { background: '||FUN.GETPROP(PRM_OBJID, 'FUNDO_TOTAL')||'; color: '||FUN.GETPROP(PRM_OBJID, 'FONTE_TOTAL')||'; }');
	
		IF  FUN.GETPROP(PRM_OBJID, 'DEGRADE') <> 'S' THEN
		    HTP.P('table#'||WS_OBJID||'c tr.cl, div#'||WS_OBJID||'fixed li.cl, div#'||WS_OBJID||'fixed li.seta.cl { background: '||FUN.GETPROP(PRM_OBJID, 'FUNDO_CLARO')||'; color: '||FUN.GETPROP(PRM_OBJID, 'FONTE_CLARO')||'; }');
		    HTP.P('table#'||WS_OBJID||'c tr.es, div#'||WS_OBJID||'fixed li.es, div#'||WS_OBJID||'fixed li.seta.es { background: '||FUN.GETPROP(PRM_OBJID, 'FUNDO_ESCURO')||'; color: '||FUN.GETPROP(PRM_OBJID, 'FONTE_ESCURO')||'; }');
		ELSE
		    HTP.P('table#'||WS_OBJID||'c tr.cl, div#'||WS_OBJID||'fixed li.cl, div#'||WS_OBJID||'fixed li.seta.cl { color: '||FUN.GETPROP(PRM_OBJID, 'FONTE_CLARO')||'; }');
		    HTP.P('table#'||WS_OBJID||'c tr.es, div#'||WS_OBJID||'fixed li.es, div#'||WS_OBJID||'fixed li.seta.es { color: '||FUN.GETPROP(PRM_OBJID, 'FONTE_ESCURO')||'; }');
		END IF;
	HTP.P('</style>');


	HTP.P('<span class="turn">');

	IF TO_NUMBER(FUN.RET_VAR('ORACLE_VERSION')) > 10 THEN
		SELECT COUNT(*) INTO WS_COUNTER FROM TABLE(FUN.VPIPE_PAR(PRM_COLUNA));
		IF WS_COUNTER = 0 AND NVL(TRIM(PRM_COLUP), 'null') = 'null' THEN
			HTP.P('<span class="arrowturn">&#x21B2;</span>');
		    IF LENGTH(TRIM(FUN.SHOW_FILTROS(TRIM(WS_PARAMETROS), WS_CURSOR, '', PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN))) > 3 THEN
			    HTP.P('<span class="filtros">F</span>');
		    END IF;
		END IF;
	END IF;

    IF LENGTH(TRIM(FUN.SHOW_FILTROS(TRIM(WS_PARAMETROS), WS_CURSOR, '', PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN))) > 3 THEN
	    IF WS_COUNTER <> 0 OR NVL(TRIM(PRM_COLUP), 'null') <> 'null' THEN
            HTP.P('<span class="filtros">F</span>');
	    END IF;
	END IF;
	
	IF LENGTH(TRIM(FUN.SHOW_DESTAQUES(TRIM(WS_PARAMETROS), WS_CURSOR, '', PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN))) > 3 THEN
		HTP.P('<span class="destaques">');
		    HTP.P('<svg style="height: calc(100% - 10px); width: calc(100% - 10px); margin: 5px; fill: #333; pointer-events: none;" enable-background="new -1.23 -8.789 141.732 141.732" height="141.732px" id="Livello_1" version="1.1" viewBox="-1.23 -8.789 141.732 141.732" width="141.732px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g id="Livello_100"><path d="M139.273,49.088c0-3.284-2.75-5.949-6.146-5.949c-0.219,0-0.434,0.012-0.646,0.031l-42.445-1.001l-14.5-37.854   C74.805,1.824,72.443,0,69.637,0c-2.809,0-5.168,1.824-5.902,4.315L49.232,42.169L6.789,43.17c-0.213-0.021-0.43-0.031-0.646-0.031   C2.75,43.136,0,45.802,0,49.088c0,2.1,1.121,3.938,2.812,4.997l33.807,23.9l-12.063,37.494c-0.438,0.813-0.688,1.741-0.688,2.723   c0,3.287,2.75,5.952,6.146,5.952c1.438,0,2.766-0.484,3.812-1.29l35.814-22.737l35.812,22.737c1.049,0.806,2.371,1.29,3.812,1.29   c3.393,0,6.143-2.665,6.143-5.952c0-0.979-0.25-1.906-0.688-2.723l-12.062-37.494l33.806-23.9   C138.15,53.024,139.273,51.185,139.273,49.088"/></g><g id="Livello_1_1_"/></svg>');
        HTP.P('</span>');
	END IF;
	
	HTP.P('</span>');

	WS_COUNTER := 0;

	IF PRM_DRILL = 'Y' THEN
	    HTP.P('<a class="fechar" id="'||WS_OBJID||'fechar" title="'||FUN.LANG('Fechar')||'"></a>');
		IF WS_ADMIN = 'A' THEN
	        HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJID||'more">');
				HTP.P(FUN.SHOWTAG(PRM_OBJID, 'atrib', PRM_SCREEN));
				
			    HTP.P('<span class="preferencias" data-visao="'||PRM_MICRO_VISAO||'" data-drill="'||PRM_DRILL||'" title="'||FUN.LANG('Propriedades')||'"></span>');
			    HTP.P(FUN.SHOWTAG(PRM_OBJID, 'filter', PRM_MICRO_VISAO));
				HTP.P('<span class="sigma" title="'||FUN.LANG('Linha calculada')||'"></span>');
			    HTP.P('<span class="lightbulb" title="Drill"></span>');
			    HTP.P(FUN.SHOWTAG(WS_OBJID||'c', 'excel'));
			    HTP.P('<span class="data_table" title="'||FUN.LANG('Alterar Consulta')||'"></span>');
				HTP.P(FUN.SHOWTAG('', 'star'));
			HTP.P('</span>');
	    ELSE
		    IF FUN.GETPROP(PRM_OBJID,'NO_OPTION') <> 'S' THEN

				IF WS_COUNT > 0 THEN
				    SELECT NVL(CS_AGRUPADOR, 'N/A') INTO WS_TPT FROM PONTO_AVALIACAO WHERE CS_AGRUPADOR IN (SELECT NVL(CD_COLUNA, 'N/A') FROM MICRO_COLUNA WHERE ST_AGRUPADOR = 'TPT' AND CD_MICRO_VISAO = PRM_MICRO_VISAO) AND CD_PONTO = PRM_OBJID;
				ELSE
				    WS_TPT := 'N/A';
				END IF;

				IF WS_TPT <> 'N/A' THEN
				    HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJID||'more" style="right: 0; max-width: 132px; max-height: 26px;">');
				ELSE
				    HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJID||'more" style="right: 0; max-width: 106px; max-height: 26px;">');
				END IF;
				
				HTP.P('<span class="lightbulb" title="Drill"></span>');
				
				HTP.P(FUN.SHOWTAG(WS_OBJID||'c', 'excel'));
				HTP.P(FUN.SHOWTAG('', 'star'));
				HTP.P('</span>');
				
			END IF;
	    END IF;
	ELSIF PRM_DRILL = 'O' THEN
	    HTP.P(WS_NULL);
	ELSE
	    IF WS_ADMIN = 'A' THEN
	    	HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJID||'more">');
				HTP.P(FUN.SHOWTAG(PRM_OBJID, 'atrib', PRM_SCREEN));
				
				HTP.P('<span class="preferencias" data-visao="'||PRM_MICRO_VISAO||'" data-drill="'||PRM_DRILL||'" title="'||FUN.LANG('Propriedades')||'"></span>');
				HTP.P(FUN.SHOWTAG(PRM_OBJID, 'filter', PRM_MICRO_VISAO));
				HTP.P('<span class="sigma" title="'||FUN.LANG('Linha calculada')||'"></span>');
				HTP.P('<span class="lightbulb" title="Drill"></span>');
	   			HTP.P(FUN.SHOWTAG(WS_OBJID||'c', 'excel'));
				HTP.P('<span class="data_table" title="'||FUN.LANG('Alterar Consulta')||'"></span>');
				HTP.P(FUN.SHOWTAG('', 'star'));
				FCL.BUTTON_LIXO('dl_obj', PRM_OBJETO => PRM_OBJID, PRM_TAG => 'span');
			HTP.P('</span>');
	   		
	    ELSE
	   		IF FUN.GETPROP(PRM_OBJID,'NO_OPTION') <> 'S' THEN

				IF WS_COUNT > 0 THEN
				    SELECT NVL(CS_AGRUPADOR, 'N/A') INTO WS_TPT FROM PONTO_AVALIACAO WHERE CS_AGRUPADOR IN (SELECT NVL(CD_COLUNA, 'N/A') FROM MICRO_COLUNA WHERE ST_AGRUPADOR = 'TPT' AND CD_MICRO_VISAO = PRM_MICRO_VISAO) AND CD_PONTO = PRM_OBJID;
				ELSE
				    WS_TPT := 'N/A';
				END IF;

				IF WS_TPT <> 'N/A' THEN
				    HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJID||'more" style="right: 0; max-width: 106px; max-height: 30px;">');
				ELSE
				    HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJID||'more" style="right: 0; max-width: 106px; max-height: 30px;">');
				END IF;
				    HTP.P('<span class="lightbulb" title="Drill"></span>');
					
					HTP.P(FUN.SHOWTAG(WS_OBJID||'c', 'excel'));
                    HTP.P(FUN.SHOWTAG('', 'star'));
				HTP.P('</span>');
			END IF;
	    END IF;
	END IF;

	BEGIN
		WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
		DBMS_SQL.PARSE( C => WS_CURSOR, STATEMENT => WS_QUERY_MONTADA, LB => 1, UB => WS_LQUERY, LFFLG => TRUE, LANGUAGE_FLAG => DBMS_SQL.NATIVE );
		WS_SQL := CORE.BIND_DIRECT(WS_PARAMETROS, WS_CURSOR, '', PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN);
		
		SELECT COUNT(*) INTO WS_LIMITE_COL
        FROM TABLE(FUN.VPIPE(WS_CAB_CROSS));

	SELECT COUNT(*) INTO WS_LINHA_CALC
	FROM LINHA_CALCULADA
	WHERE CD_MICRO_VISAO = PRM_MICRO_VISAO AND
	CD_OBJETO = PRM_OBJID;

		WS_COUNTER := 0;
		LOOP
		    WS_COUNTER := WS_COUNTER + 1;
		    IF  WS_COUNTER > (WS_LIMITE_COL + WS_LINHA_CALC) THEN
		    	EXIT;
		    END IF;
		    DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, RET_COLUNA, 2000);
		END LOOP;

		WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);
		WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_CURSOR);
		IF  WS_LINHAS = 1 THEN
		    WS_VAZIO := FALSE;
	    ELSE
	        DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
	        WS_VAZIO := TRUE;
      		RAISE WS_NODATA;
        END IF;
		DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
	EXCEPTION
	    WHEN OTHERS THEN
	    	RAISE WS_PARSEERR;
	END;

	HTP.FORMOPEN( CATTRIBUTES => 'name="busca" style="display: none;"', CURL =>'A', CMETHOD => 'post');
		IF  PRM_DRILL <> 'Y' THEN
		    HTP.P( '<input type="hidden" name="show_'||WS_OBJID||'" id="show_'||WS_OBJID||'" value="prm_drill=N&prm_objeto='||PRM_OBJID||'&PRM_POSX='||WS_POSIX||'&PRM_ZINDEX='||PRM_ZINDEX||'&PRM_POSY='||WS_POSIY||'&prm_parametros='||WS_PARAMETROS||'&prm_screen='||PRM_SCREEN||'&prm_track=&prm_objeton=" />');
		END IF;
		HTP.P( '<input type="hidden" name="npar_'||WS_OBJID||'" id="par_'||WS_OBJID||'" value="'||WS_PARAMETROS||'" />');
		HTP.P( '<input type="hidden" name="nord_'||WS_OBJID||'" id="ord_'||WS_OBJID||'" value="'||WS_ORDEM||'" />');
		HTP.P( '<input type="hidden" name="nmvs_'||WS_OBJID||'" id="mvs_'||WS_OBJID||'" value="'||PRM_MICRO_VISAO||'" />');
		HTP.P( '<input type="hidden" name="ncol_'||WS_OBJID||'" id="col_'||WS_OBJID||'" value="'||WS_COLUNA||'" />');
		HTP.P( '<input type="hidden" name="nagp_'||WS_OBJID||'" id="agp_'||WS_OBJID||'" value="'||WS_AGRUPADOR||'" />');
		HTP.P( '<input type="hidden" name="nrps_'||WS_OBJID||'" id="rps_'||WS_OBJID||'" value="'||WS_RP||'" />');
		HTP.P( '<input type="hidden" name="ndri_'||WS_OBJID||'" id="dri_'||WS_OBJID||'" value="'||WS_DRILL||'" />');
		HTP.P( '<input type="hidden" name="ncup_'||WS_OBJID||'" id="cup_'||WS_OBJID||'" value="'||WS_COLUP||'" />');
		HTP.P( '<input type="hidden" name="nsco_'||WS_OBJID||'" id="sco_'||WS_OBJID||'" value="" />' );
    	HTP.P( '<input type="hidden" name="ndrl_'||WS_OBJID||'" id="drill_'||WS_OBJID||'" value='||CHR(39)||FUN.CALL_DRILL(PRM_DRILL, WS_PARAMETROS, PRM_SCREEN, PRM_OBJID, PRM_MICRO_VISAO, PRM_COLUNA, 1, PRM_TRACK, PRM_OBJETON)||CHR(39)||' />' );
    	HTP.P( '<input type="hidden" name="ndrl_'||WS_OBJID||'" id="drill2_'||WS_OBJID||'" value='||CHR(39)||FUN.CALL_DRILL(PRM_DRILL, WS_PARAMETROS, PRM_SCREEN, PRM_OBJID, PRM_MICRO_VISAO, PRM_COLUNA, 2, PRM_TRACK, PRM_OBJETON)||CHR(39)||' />' );
	HTP.FORMCLOSE;
	
	SELECT NM_OBJETO INTO WS_NOME FROM OBJETOS WHERE CD_OBJETO = PRM_OBJID;

	IF  NVL(PRM_OBJID,'%?%')<>'%?%' THEN
		    WS_TITULO := WS_NOME;
		ELSE
		    WS_TITULO := '';
	END IF;

	IF  FUN.GETPROP(PRM_OBJID, 'TOP') <> 'X' THEN
        WS_TOP := FUN.GETPROP(PRM_OBJID, 'TOP');
    END IF;

	WS_TITLE := WS_QUERYOC;

	IF  PRM_DRILL='Y' THEN
		IF WS_ADMIN = 'A' THEN
			HTP.P('<span style="text-align: '||FUN.GETPROP(PRM_OBJID,'ALIGN_TIT')||'; background-color: '||FUN.GETPROP(PRM_OBJID,'FUNDO_TIT')||'; color: '||FUN.GETPROP(PRM_OBJID,'FONTE_TIT')||';" id="'||WS_OBJID||'_ds" ondblclick="curtain(''''); scale('''||WS_OBJID||''');" data-touch="0" ontouchstart="document.getElementById('''||WS_OBJID||''').style.opacity=0.7;" ontouchend="document.getElementById('''||WS_OBJID||''').style.opacity=1; dblTouch('''||WS_OBJID||''');" title="'||WS_OBJID||'" class="wd_move" onmouseup="document.getElementById('''||WS_OBJID||''').style.opacity=1;" onmousedown="document.getElementById('''||WS_OBJID||''').style.opacity=0.7;">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', PRM_OBJID, WS_TITULO), PRM_SCREEN)||'</span>');
		ELSE
		    HTP.P('<span style="text-align: '||FUN.GETPROP(PRM_OBJID,'ALIGN_TIT')||'; background-color: '||FUN.GETPROP(PRM_OBJID,'FUNDO_TIT')||'; color: '||FUN.GETPROP(PRM_OBJID,'FONTE_TIT')||';" id="'||WS_OBJID||'_ds" ondblclick="curtain(''''); scale('''||WS_OBJID||''');" data-touch="0" ontouchstart="document.getElementById('''||WS_OBJID||''').style.opacity=0.7;" ontouchend="document.getElementById('''||WS_OBJID||''').style.opacity=1; dblTouch('''||WS_OBJID||''');" title="'||FUN.LANG('clique e arraste para mover')||'" onmouseup="document.getElementById('''||WS_OBJID||''').style.opacity=1;" onmousedown="document.getElementById('''||WS_OBJID||''').style.opacity=0.7;" class="wd_move">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', PRM_OBJID, WS_TITULO), PRM_SCREEN)||'</span>');
		END IF;
	ELSE
		IF WS_ADMIN = 'A' THEN
		    HTP.P('<span style="text-align: '||FUN.GETPROP(PRM_OBJID,'ALIGN_TIT')||'; background-color: '||FUN.GETPROP(PRM_OBJID,'FUNDO_TIT')||'; color: '||FUN.GETPROP(PRM_OBJID,'FONTE_TIT')||';" id="'||WS_OBJID||'_ds" ondblclick="curtain(''''); scale('''||WS_OBJID||''');" data-touch="0" ontouchend="dblTouch('''||WS_OBJID||'''); invisible_touch('''||WS_OBJID||''', ''stop'');" data-touch="0" title="'||WS_OBJID||'" class="wd_move" ontouchstart="invisible_touch('''||WS_OBJID||''', ''start'');" onmousedown="invisible_touch('''||WS_OBJID||''', ''start''); " onmouseup="invisible_touch('''||WS_OBJID||''', ''stop'');">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', PRM_OBJID, WS_TITULO), PRM_SCREEN)||'</span>');
		ELSE
		    HTP.P('<span style="text-align: '||FUN.GETPROP(PRM_OBJID,'ALIGN_TIT')||'; background-color: '||FUN.GETPROP(PRM_OBJID,'FUNDO_TIT')||'; color: '||FUN.GETPROP(PRM_OBJID,'FONTE_TIT')||';" id="'||WS_OBJID||'_ds" ondblclick="curtain(''''); scale('''||WS_OBJID||''');" data-touch="0" ontouchend="dblTouch('''||WS_OBJID||''');" data-touch="0" class="no_move">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', PRM_OBJID, WS_TITULO), PRM_SCREEN)||'</span>');
		END IF;
	END IF;


	HTP.P('<ul id="'||WS_OBJID||'-filterlist" style="display: none;">');
	    HTP.P(FUN.SHOW_FILTROS(TRIM(WS_PARAMETROS), WS_CURSOR, '', PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN));
	HTP.P('</ul>');
	
	HTP.P('<ul id="'||WS_OBJID||'-destaquelist" style="display: none;" >');
	    HTP.P(FUN.SHOW_DESTAQUES(TRIM(WS_PARAMETROS), WS_CURSOR, '', PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN));
	HTP.P('</ul>');

	BEGIN
		IF FUN.GETPROP(PRM_OBJID, 'LARGURA') <> 0 THEN
			WS_LARGURA := TO_NUMBER(FUN.GETPROP(PRM_OBJID, 'LARGURA'));
		ELSE
			WS_LARGURA := TO_NUMBER('4000');
		END IF;
    EXCEPTION WHEN OTHERS THEN
	    WS_LARGURA := TO_NUMBER('4000');
	END;
	
	BEGIN
		IF FUN.GETPROP(PRM_OBJID, 'ALTURA') <> 0 THEN
			WS_CTEMP := TO_NUMBER(FUN.GETPROP(PRM_OBJID, 'ALTURA'))+14;
		ELSE
			WS_CTEMP := TO_NUMBER('6000');
		END IF;
	EXCEPTION WHEN OTHERS THEN
	    WS_CTEMP := TO_NUMBER('6000');
	END;

	HTP.P('<div class="header" id="'||WS_OBJID||'header" style="background-color: '||FUN.GETPROP(PRM_OBJID, 'FUNDO_VALOR')||'; max-width: '||WS_LARGURA||'px;"></div>');

	IF FUN.GETPROP(PRM_OBJID, 'DEGRADE') = 'S' THEN
	    HTP.P('<div class="fonte" data-resize="" data-maxheight="'||WS_CTEMP||'" data-maxwidth="'||WS_LARGURA||'" style="max-width: '||WS_LARGURA||'px; '||FCL.FPDATA(WS_CTEMP,'0','',' max-height: '||WS_CTEMP||'px; cursor: default; ')||' background: -webkit-linear-gradient('||FUN.GETPROP(PRM_OBJID, 'FUNDO_CLARO')||', '||FUN.GETPROP(PRM_OBJID, 'FUNDO_ESCURO')||'); background: linear-gradient('||FUN.GETPROP(PRM_OBJID, 'FUNDO_CLARO')||', '||FUN.GETPROP(PRM_OBJID, 'FUNDO_ESCURO')||'); " id="'||WS_OBJID||'dv2">');
	ELSE
		HTP.P('<div class="fonte" data-resize="" data-maxheight="'||WS_CTEMP||'" data-maxwidth="'||WS_LARGURA||'" style="max-width: '||WS_LARGURA||'px; '||FCL.FPDATA(WS_CTEMP,'0','',' max-height: '||WS_CTEMP||'px; cursor: default; ')||'" id="'||WS_OBJID||'dv2">');
	END IF;

	HTP.P('<div id="'||WS_OBJID||'m">');
	
	
	HTP.TABLEOPEN( CATTRIBUTES => ' id="'||WS_OBJID||'c" ');

	WS_COUNTER   := 0;
	WS_COUNTERID := 1;
	WS_CCOLUNA   := 0;
    WS_STEP := 0;

	WS_FIRSTID := 'Y';

	WS_CURSOR := DBMS_SQL.OPEN_CURSOR;

	DBMS_SQL.PARSE( C => WS_CURSOR, STATEMENT => WS_QUERY_MONTADA, LB => 1, UB => WS_LQUERY, LFFLG => TRUE, LANGUAGE_FLAG => DBMS_SQL.NATIVE );

	WS_SQL := CORE.BIND_DIRECT(WS_PARAMETROS, WS_CURSOR, '', PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN);

	WS_COUNTER := 0;
	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > (WS_LIMITE_COL + WS_LINHA_CALC) THEN
	    	EXIT;
	    END IF;
	    DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, RET_COLUNA, 2000);
	END LOOP;
	WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);

	WS_COUNTER := 0;
	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > (WS_LIMITE_COL + WS_LINHA_CALC) THEN
		EXIT;
	    END IF;

	    WS_CCOLUNA := 1;
	    LOOP
		IF  WS_CCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
		    EXIT;
		END IF;
		WS_CCOLUNA := WS_CCOLUNA + 1;
	    END LOOP;

	    IF  RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' THEN
	        WS_VCOL(WS_COUNTER) := RET_MCOL(WS_CCOLUNA).CD_COLUNA;
	        WS_VCON(WS_COUNTER) := 'First';
	    END IF;

	    WS_COLUNA_ANT(WS_COUNTER) := 'First';
	END LOOP;

	HTP.P('<tbody></tbody>');
	
	HTP.P('<thead>');

        SELECT CD_LIGACAO INTO WS_LIGACAO FROM MICRO_COLUNA WHERE CD_COLUNA = WS_COLUNA AND CD_MICRO_VISAO = PRM_MICRO_VISAO;
	
	    HTP.P('<tr class="escuro" style="background: '||FUN.GETPROP(PRM_OBJID, 'FUNDO_CABECALHO')||'; color: '||FUN.GETPROP(PRM_OBJID, 'FONTE_CABECALHO')||';">');
			FOR I IN (SELECT COLUMN_VALUE FROM TABLE(FUN.VPIPE((WS_CAB_CROSS)))) LOOP
				IF I.COLUMN_VALUE = WS_COLUNA THEN
					IF NVL(WS_LIGACAO, 'SEM') <> 'SEM' THEN
					    HTP.PRN('<th>#</th>');
					ELSE
					    HTP.PRN('<th>'||FUN.NOME_COL(I.COLUMN_VALUE, PRM_MICRO_VISAO)||'</th>');
					END IF;
				ELSE
					HTP.PRN('<th>'||I.COLUMN_VALUE||'</th>');
				END IF;
			END LOOP;
	    HTP.P('</tr>');

		
		IF NVL(WS_LIGACAO, 'SEM') <> 'SEM' THEN
             HTP.P('<tr class="escuro" style="background: '||FUN.GETPROP(PRM_OBJID, 'FUNDO_CABECALHO')||'; color: '||FUN.GETPROP(PRM_OBJID, 'FONTE_CABECALHO')||';">');
				FOR I IN (SELECT COLUMN_VALUE FROM TABLE(FUN.VPIPE((WS_CAB_CROSS)))) LOOP
					IF I.COLUMN_VALUE = WS_COLUNA THEN
						HTP.PRN('<th>'||FUN.NOME_COL(I.COLUMN_VALUE, PRM_MICRO_VISAO)||'</th>');
					ELSE
						HTP.PRN('<th>'||FUN.CDESC(I.COLUMN_VALUE, WS_LIGACAO)||'</th>');
					END IF;
				END LOOP;
	    	HTP.P('</tr>');
		END IF;
	
	HTP.P('</thead>');

	WS_ZEBRADO   := 'First';
	WS_ZEBRADO_D := 'First';
    
    

	HTP.P('<tbody>');

	LOOP
	    WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_CURSOR);
	    IF  WS_LINHAS = 1 THEN
		    WS_VAZIO := FALSE;
	    ELSE
            IF  WS_VAZIO = TRUE THEN
	            DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
      		    RAISE WS_NODATA;
        	END IF;
        	EXIT;
	    END IF;

		WS_CT_TOP := WS_CT_TOP + 1;
        IF  WS_TOP <> 0 AND WS_CT_TOP > WS_TOP THEN
            EXIT;
        END IF;

		IF  WS_ZEBRADO IN ('First','Escuro') THEN
			WS_ZEBRADO   := 'Claro';
			WS_ZEBRADO_D := 'Distinto_claro';
		ELSE
			WS_ZEBRADO   := 'Escuro';
			WS_ZEBRADO_D := 'Distinto_escuro';
		END IF;

	    WS_COUNTER := 0;
	    WS_CCOLUNA := 0;
	    WS_CHCOR   := 0;
	    WS_CTNULL  := 0;
	    WS_CTCOL   := 0;

	    LOOP

		WS_COUNTER := WS_COUNTER + 1;
		IF  WS_COUNTER > (WS_LIMITE_COL + WS_LINHA_CALC) THEN
		    EXIT;
		END IF;

		WS_XCOLUNA := 1;
		LOOP
		    IF  WS_XCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_XCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
				EXIT;

		    END IF;
		    WS_XCOLUNA := WS_XCOLUNA + 1;
		END LOOP;

		WS_CCOLUNA := WS_CCOLUNA + 1;
		DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_CCOLUNA, RET_COLUNA);

		IF  WS_CCOLUNA = 1 THEN
		    RET_COLUNA := SUBSTR(RET_COLUNA,6,LENGTH(RET_COLUNA));
			WS_REFCOL := RET_COLUNA;
		END IF;

		IF  RET_MCOL(WS_XCOLUNA).ST_AGRUPADOR = 'SEM' THEN
		    WS_CTCOL  := WS_CTCOL + 1;
		END IF;

	    END LOOP;

	    WS_XATALHO := '';
	    WS_PIPE    := '';
	    WS_BINDN := WS_VCOL.FIRST;
	    WHILE WS_BINDN IS NOT NULL LOOP
		IF  WS_BINDN = 1 OR WS_NCOLUMNS(WS_BINDN) <> WS_NCOLUMNS(WS_BINDN-1) THEN
		    DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_BINDN, RET_COLUNA);
		    WS_VCON(WS_BINDN) := RET_COLUNA;
		    DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_BINDN, RET_COLUNA);
		    IF  NVL(RET_COLUNA,'%*') <> '%*' THEN
		        WS_XATALHO := WS_XATALHO||WS_PIPE;
			WS_XATALHO := TRIM(WS_XATALHO)||WS_VCOL(WS_BINDN);
			WS_PIPE    := '|';
		    END IF;
		END IF;
		WS_BINDN := WS_VCOL.NEXT(WS_BINDN);
	    END LOOP;
	    
	    

		WS_LINHA := WS_LINHA+1;
		IF  RET_COLGRP <> 0 THEN
			HTP.TABLEROWOPEN( CATTRIBUTES => 'class="total"');
		ELSE
			IF(WS_ZEBRADO = 'Escuro') THEN
			  HTP.TABLEROWOPEN( CATTRIBUTES => 'class="es"');
			ELSE
			  HTP.TABLEROWOPEN( CATTRIBUTES => 'class="cl"');
			END IF;
		END IF;

		IF(LENGTH(WS_TMP_JUMP) > 5) THEN
		    WS_CHECK := WS_TMP_CHECK;
		END IF;

		WS_DRILL_ATALHO := REPLACE('|'||TRIM(WS_XATALHO),'||','|');
		IF(INSTR(WS_DRILL_ATALHO, '|', 1, 1) = 1) THEN
		  WS_DRILL_ATALHO := SUBSTR(WS_DRILL_ATALHO,2,LENGTH(WS_DRILL_ATALHO));
		END IF;

		WS_JUMP := WS_TMP_JUMP;

		



		IF RET_COLGRP = 0 THEN
		    HTP.P('<td '||WS_CHECK||' style="'||WS_JUMP||'" data-valor="'||WS_VCOL(1)||'"></td>');
		END IF;

	    WS_COUNTER := 0;

		WS_LIMITE_I := FUN.GETPROP(PRM_OBJID,'COLUNA_INICIAL');
        WS_LIMITE_F := FUN.GETPROP(PRM_OBJID,'COLUNA_FINAL');
        WS_LINHA_ACUMULADA := FUN.GETPROP(PRM_OBJID,'LINHA_ACUMULADA');
		WS_TOTAL_ACUMULADO := FUN.GETPROP(PRM_OBJID,'TOTAL_ACUMULADO');

	    LOOP
		WS_COUNTER := WS_COUNTER + 1;
		IF  WS_COUNTER > (WS_LIMITE_COL + WS_LINHA_CALC) THEN
		    EXIT;
		END IF;


		BEGIN
		    IF(WS_COUNTER) < WS_STEP-(WS_STEPPER) THEN
		        
		        WS_ATALHO := WS_MFILTRO(WS_COUNTER+1);
			ELSE
			    WS_ATALHO := '';
			END IF;
		EXCEPTION
		    WHEN OTHERS THEN
			WS_ATALHO := '';
		END;

		 WS_CCOLUNA := 1;
		  LOOP
			  IF RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_REFCOL THEN
				  EXIT;
			  END IF;
			  WS_CCOLUNA := WS_CCOLUNA + 1;
		  END LOOP;

		DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_COUNTER, RET_COLUNA);

		RET_COLUNA := REPLACE(RET_COLUNA,'"','*');
		RET_COLUNA := REPLACE(RET_COLUNA,'/',' ');

		IF  WS_FIRSTID = 'Y' THEN
		    WS_IDCOL := ' id="'||WS_OBJID||WS_COUNTER||'l" ';
		ELSE
		    WS_IDCOL := '';
		END IF;

		WS_DRILL_ATALHO := REPLACE(TRIM(WS_ATALHO)||'|'||TRIM(WS_XATALHO),'||','|');
		IF(INSTR(WS_DRILL_ATALHO, '|', 1, 1) = 1) THEN
		  WS_DRILL_ATALHO := SUBSTR(WS_DRILL_ATALHO,2,LENGTH(WS_DRILL_ATALHO));
		END IF;

		





		IF(LENGTH(WS_JUMP) > 1) THEN
		  WS_JUMP := 'style="'||WS_JUMP||'"';
		END IF;

		IF(RTRIM(RET_MCOL(WS_CCOLUNA).ST_INVISIVEL) <> 'S') THEN
			IF(RTRIM(RET_MCOL(WS_CCOLUNA).ST_ALINHAMENTO) = 'RIGHT') THEN
				IF(RTRIM(RET_MCOL(WS_CCOLUNA).ST_NEGRITO) = 'S') THEN
				    WS_JUMP := WS_JUMP||' class="dir bld"';
				ELSE
				    WS_JUMP := WS_JUMP||' class="dir"';
				END IF;
			ELSIF(RTRIM(RET_MCOL(WS_CCOLUNA).ST_ALINHAMENTO) = 'CENTER') THEN
				IF(RTRIM(RET_MCOL(WS_CCOLUNA).ST_NEGRITO) = 'S') THEN
				    WS_JUMP := WS_JUMP||' class="cen bld"';
				ELSE
				    WS_JUMP := WS_JUMP||' class="cen"';
				END IF;
			ELSE
			    IF(RTRIM(RET_MCOL(WS_CCOLUNA).ST_NEGRITO) = 'S') THEN
				    WS_JUMP := WS_JUMP||' class="bld"';
				END IF;
			END IF;

		ELSE
			WS_JUMP := WS_JUMP||' class="no_font"';
		END IF;

		WS_JUMP := TRIM(WS_JUMP);

		IF  RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_REFCOL THEN
		    WS_CONTENT := FUN.NOME_COL(RET_COLUNA, PRM_MICRO_VISAO);
		ELSE
		    WS_CONTENT := RET_COLUNA;
		END IF;

		IF  WS_LINHA_ACUMULADA = 'S' AND RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR <> 'SEM' AND WS_COUNTER < WS_NCOLUMNS.COUNT AND RET_COLGRP = 0  THEN

			IF  WS_COUNTER > WS_LIMITE_I AND WS_COUNTER < (WS_NCOLUMNS.COUNT)-WS_LIMITE_F AND WS_SCOL = 1 THEN
				BEGIN
					WS_TEMP_VALOR := TO_NUMBER(NVL(RET_COLUNA, '0'));
				EXCEPTION WHEN OTHERS THEN
				    WS_TEMP_VALOR := 0;
				END;

				WS_ACUMULADA_LINHA := WS_ACUMULADA_LINHA + WS_TEMP_VALOR;
				WS_CONTENT     := WS_ACUMULADA_LINHA;

			ELSE
			    WS_CONTENT := RET_COLUNA;
			END IF;
		ELSE
		    WS_CONTENT := RET_COLUNA;
		END IF;


		IF LENGTH(TRIM(WS_ATALHO)) > 0 THEN
		    WS_PIVOT := 'data-p="'||TRIM(WS_ATALHO)||'"';
		END IF;
		IF  RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' AND RET_COLUNA = WS_COLUNA_ANT(WS_COUNTER) THEN
		HTP.TABLEDATA(FCL.FPDATA((WS_CTNULL - WS_CTCOL),0,'','')||FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA), PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN), CALIGN => '', CATTRIBUTES => ' ');

		ELSE
		    IF RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' THEN

			HTP.TABLEDATA(FCL.FPDATA((WS_CTNULL - WS_CTCOL),0,'','')||FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA),PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN), CALIGN => '', CATTRIBUTES => ' ');

			ELSE
		        WS_CONTENT := WS_CONTENT;
		        IF(RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR IN ('PSM','PCT') AND RET_COLGRP = 0) OR (RET_MCOL(WS_CCOLUNA).ST_GERA_REL = 'N' AND RET_COLGRP = 0) THEN
		            WS_CONTENT := ' ';
		        END IF;
				IF RET_COLGRP <> 0 AND WS_SCOL = 1 THEN
					IF WS_TOTAL_ACUMULADO = 'S' THEN
						IF WS_CCOLUNA > WS_LIMITE_I AND WS_CCOLUNA < ((WS_NCOLUMNS.COUNT-1)-WS_LIMITE_F) THEN
							BEGIN
								WS_TEMP_VALOR := TO_NUMBER(WS_CONTENT);
							EXCEPTION
								WHEN OTHERS THEN
									 WS_TEMP_VALOR := 0;
							END;
							WS_TOTAL_LINHA := WS_TOTAL_LINHA + WS_TEMP_VALOR;
							WS_CONTENT     := WS_TOTAL_LINHA;
						END IF;
					END IF;

					HTP.TABLEDATA(FUN.UM(RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_MICRO_VISAO, FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA), PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN)), CALIGN => '', CATTRIBUTES => FUN.CHECK_BLINK_TOTAL(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT, '', PRM_SCREEN)||
					' '||WS_JUMP||' '||WS_PIVOT||' ');
				ELSE

					IF  WS_COUNTER = 1 THEN
					    HTP.TABLEDATA(FUN.NOME_COL(SUBSTR(WS_CONTENT,6,LENGTH(WS_CONTENT)), PRM_MICRO_VISAO), CALIGN => '', CATTRIBUTES => 
			            ' '||WS_JUMP||' '||WS_PIVOT||' ' );
					ELSE
					    HTP.TABLEDATA(FUN.UM(RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_MICRO_VISAO, FUN.IFMASCARA(FUN.NOME_COL(WS_CONTENT, PRM_MICRO_VISAO),RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA), PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN)), CALIGN => '', CATTRIBUTES => 
			            ' '||WS_JUMP||' '||WS_PIVOT||' ' );
					END IF;

				END IF;
			END IF;
		END IF;

		IF LENGTH(FUN.CHECK_BLINK_LINHA(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_LINHA, RET_COLUNA, PRM_SCREEN)) > 7 AND RET_COLGRP = 0 THEN
		    WS_BLINK_LINHA := FUN.CHECK_BLINK_LINHA(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_LINHA, RET_COLUNA, PRM_SCREEN);
		END IF;

		WS_JUMP := '';
		WS_CHECK := '';

		WS_COLUNA_ANT(WS_COUNTER) := RET_COLUNA;
	    END LOOP;

		IF WS_BLINK_LINHA <> 'N/A' THEN HTP.P(WS_BLINK_LINHA); END IF;
	    WS_BLINK_LINHA := 'N/A';

	    WS_FIRSTID := 'N';
	    HTP.TABLEROWCLOSE;
		WS_ACUMULADA_LINHA := 0;
		WS_TOTAL_LINHA := 0;
	END LOOP;
	WS_ACUMULADA_LINHA := 0;
	WS_TOTAL_LINHA := 0;
	DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
	HTP.P('</tbody>');
	HTP.TABLECLOSE;
	HTP.P('</div>');
	WS_TEXTOT := '';
	WS_PIPE   := '';
	WS_COUNTER := 0;

	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > (WS_LIMITE_COL + WS_LINHA_CALC) THEN
		    EXIT;
	    END IF;

	    WS_CCOLUNA := 1;
	    LOOP
		IF  WS_CCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
		    EXIT;
		END IF;
		WS_CCOLUNA := WS_CCOLUNA + 1;
	    END LOOP;

	    IF  RET_MCOL(WS_CCOLUNA).CD_LIGACAO <> 'SEM' AND RET_MCOL(WS_CCOLUNA).ST_COM_CODIGO = 'S' THEN
		WS_TEXTOT := WS_TEXTOT||WS_PIPE||'2';
		WS_PIPE   := '|';
		WS_COUNTER := WS_COUNTER + 1;
	    ELSE
		WS_TEXTOT := WS_TEXTOT||WS_PIPE||'1';
		WS_PIPE   := '|';
	    END IF;
	END LOOP;

	HTP.P( '<input type="hidden" name="seqw_'||WS_OBJID||'" id="seqx_'||WS_OBJID||'" value="'||TRIM(WS_TEXTOT)||'" >');
	HTP.P( '<input type="hidden" name="csxq_'||WS_OBJID||PRM_CCOUNT||'" id="cseq_'||WS_OBJID||PRM_CCOUNT||'" value="'||TRIM(WS_TEXTOT)||'" >');
	HTP.P('</div>');
	IF  PRM_DRILL!='Y' THEN
		HTP.P('</div>');
	END IF;
	HTP.P('</div>');

EXCEPTION
        WHEN WS_MOUNT THEN
	     FCL.INICIAR;
        WHEN WS_CLOSE_HTML THEN
	     FCL.POSICIONA_OBJETO('newquery','DWU','DEFAULT','DEFAULT');
	    WHEN WS_PARSEERR   THEN
	    IF WS_VAZIO THEN
            INSERT INTO LOG_EVENTOS VALUES(SYSDATE, PRM_MICRO_VISAO||'/'||WS_COLUNA||'/'||TRIM(WS_PARAMETROS)||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR, WS_USUARIO, 'VAZIO', 'ERRORLINE', '01');
            INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - VAZIO', WS_USUARIO, 'ERRO');
            COMMIT;
        ELSE
            INSERT INTO LOG_EVENTOS VALUES(SYSDATE, PRM_MICRO_VISAO||'/'||WS_COLUNA||'/'||TRIM(WS_PARAMETROS)||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR, WS_USUARIO, 'NOVAZIO', 'PARSE', '01');
		    INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - PARSEERR', WS_USUARIO, 'ERRO');
            COMMIT;
		END IF;
	    COMMIT;
		HTP.P('<p style="display: none;">'||WS_CAB_CROSS||'  -   '||WS_NCOLUMNS.COUNT||'</p>');
		HTP.P('<span class="wd_move" style="text-align: '||FUN.GETPROP(PRM_OBJID,'ALIGN_TIT')||'; background-color: '||FUN.GETPROP(PRM_OBJID,'FUNDO_TIT')||'; color: '||FUN.GETPROP(PRM_OBJID,'FONTE_TIT')||'; text-align: center; text-transform: uppercase; font-weight: bold; cursor: move; display: block;">'||FUN.LANG('Sem Dados')||'</span>');
		IF WS_ADMIN = 'A' THEN
		HTP.TABLEOPEN( CATTRIBUTES => ' id="'||WS_OBJID||'c" style="max-width: 760px; overflow: auto; display: inline-block;"');
		    HTP.TABLEROWOPEN( CATTRIBUTES => 'style="background: '||FUN.GETPROP(PRM_OBJID, 'FUNDO_CABECALHO')||'; color: '||FUN.GETPROP(PRM_OBJID, 'FONTE_CABECALHO')||';" border="0" id="'||WS_OBJID||'_tool" ');
			FCL.TABLEDATAOPEN( CCOLSPAN => WS_LIMITE_COL, CALIGN => 'LEFT');
			FCL.TABLEDATACLOSE;
		    HTP.TABLEROWCLOSE;
		    HTP.P('<ul>');
			HTP.P(FUN.SHOW_FILTROS(TRIM(WS_PARAMETROS), WS_CURSOR, '', PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN) );
			HTP.P('</ul>');
    		HTP.TABLEROWOPEN( CATTRIBUTES => ' style="background: '||FUN.GETPROP(PRM_OBJID, 'FUNDO_CABECALHO')||'; color: '||FUN.GETPROP(PRM_OBJID, 'FONTE_CABECALHO')||';" border="0" id="'||WS_OBJID||'_tool" ');
			FCL.TABLEDATAOPEN( CCOLSPAN => WS_LIMITE_COL, CALIGN => 'LEFT');
			HTP.P('<div style="white-space: pre-line; font-size: 15px; text-align: center; cursor: pointer;" onclick="paste = encodeURIComponent(this.innerHTML.trim()); alerta(''feed-fixo'', ''query copiada!'');">');
			WS_COUNTER := 0;
			LOOP
				WS_COUNTER := WS_COUNTER + 1;
				IF  WS_COUNTER > WS_QUERY_MONTADA.COUNT THEN
				    EXIT;
				END IF;
				HTP.P(WS_QUERY_MONTADA(WS_COUNTER));
			END LOOP;
			HTP.P('</div>');
			FCL.TABLEDATACLOSE;
		    HTP.TABLEROWCLOSE;
		    HTP.TABLECLOSE;
		END IF;
		HTP.P('<div align="center"><img alt="'||FUN.LANG('alerta')||'" src="'||FUN.R_GIF('warning','PNG')||'"></div>');
		HTP.P('</div>');
    WHEN WS_INVALIDO   THEN
        INSERT INTO LOG_EVENTOS VALUES(SYSDATE, PRM_MICRO_VISAO||'/'||WS_COLUNA||'/'||TRIM(WS_PARAMETROS)||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR, WS_USUARIO, 'INVALIDO', 'E-ACC', '01');
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, 'ERRORLINE: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - INVALIDO', WS_USUARIO, 'ERRO');
        COMMIT;
	    FCL.NEGADO(FUN.LANG('Parametros Invalidos'));
	WHEN WS_ACESSO	     THEN
	   FCL.NEGADO(PRM_MICRO_VISAO||'visao');
	WHEN WS_SEMQUERY     THEN
        INSERT INTO LOG_EVENTOS VALUES(SYSDATE, PRM_MICRO_VISAO||'/'||WS_COLUNA||'/'||TRIM(WS_PARAMETROS)||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR, WS_USUARIO, 'SEMQUERY', 'SEMQUERY', '01');
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SEMQUERY', WS_USUARIO, 'ERRO');
        COMMIT;
	    FCL.NEGADO('['||PRM_MICRO_VISAO||']-['||PRM_OBJID||']-'||FUN.LANG('Relat&oacute;rio Sem Query'));
	WHEN WS_NODATA	     THEN
		INSERT INTO LOG_EVENTOS VALUES(SYSDATE, PRM_MICRO_VISAO||'/'||WS_COLUNA||'/'||TRIM(WS_PARAMETROS)||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR, WS_USUARIO, 'NODATA', 'NODATA', '01');
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - NODATA', WS_USUARIO, 'ERRO');
        COMMIT;
        HTP.P('</div>');
		FCL.NEGADO(PRM_MICRO_VISAO||' - '||FUN.LANG('Sem Dados no relat&oacute;rio')||'.');
		HTP.P('</div>');
	WHEN WS_SEMPERMISSAO THEN
	   FCL.NEGADO(PRM_MICRO_VISAO||' - '||FUN.LANG('Sem Permiss&atilde;o Para Este Filtro')||'.');
    WHEN OTHERS	     THEN
        INSERT INTO LOG_EVENTOS VALUES(SYSDATE, PRM_MICRO_VISAO||'/'||WS_COLUNA||'/'||TRIM(WS_PARAMETROS)||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR, WS_USUARIO, 'OTHER', 'ERRORLINE', '01');
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - TAB_CROSS', WS_USUARIO, 'ERRO');
        COMMIT;

		HTP.P('<span class="errorquery">'||SQLERRM||'</span>');
END TAB_CROSS;

PROCEDURE SUBQUERY ( PRM_OBJID       VARCHAR2 DEFAULT NULL,
					 PRM_PARAMETROS  VARCHAR2 DEFAULT '1|1',
					 PRM_MICRO_VISAO VARCHAR2 DEFAULT NULL,
					 PRM_COLUNA	 	 VARCHAR2 DEFAULT NULL,
					 PRM_AGRUPADOR	 VARCHAR2 DEFAULT NULL,
					 PRM_RP		 	 VARCHAR2 DEFAULT 'GROUP',
					 PRM_COLUP	 	 VARCHAR2 DEFAULT NULL,
					 PRM_SCREEN		 VARCHAR2 DEFAULT 'DEFAULT',
					 PRM_CCOUNT		 CHAR DEFAULT '0',
					 PRM_DRILL		 CHAR DEFAULT 'N',
					 PRM_ORDEM		 NUMBER DEFAULT 1,
					 PRM_SELF        VARCHAR2 DEFAULT NULL ) AS

	CURSOR CRS_MICRO_VISAO IS
			SELECT	RTRIM(CD_GRUPO_FUNCAO) AS CD_GRUPO_FUNCAO
			FROM 	MICRO_VISAO WHERE NM_MICRO_VISAO = PRM_MICRO_VISAO;

	WS_MICRO_VISAO CRS_MICRO_VISAO%ROWTYPE;

	CURSOR CRS_XGOTO(PRM_USUARIO VARCHAR2) IS
			SELECT	RTRIM(CD_OBJETO_GO) AS CD_OBJETO_GO
			FROM 	GOTO_OBJETO WHERE CD_OBJETO = PRM_OBJID AND
			        CD_OBJETO_GO NOT IN ( SELECT CD_OBJETO FROM OBJECT_RESTRICTION WHERE USUARIO = PRM_USUARIO )
			ORDER BY CD_OBJETO_GO;

	WS_XGOTO CRS_XGOTO%ROWTYPE;

	TYPE WS_TMCOLUNAS IS TABLE OF MICRO_COLUNA%ROWTYPE
			    		INDEX BY PLS_INTEGER;

	TYPE GENERIC_CURSOR IS REF CURSOR;

	CRS_SAIDA GENERIC_CURSOR;

	CURSOR NC_COLUNAS IS SELECT * FROM MICRO_COLUNA WHERE CD_MICRO_VISAO = PRM_MICRO_VISAO;

	RET_COLUNA			VARCHAR2(4000);
	RET_MCOL			WS_TMCOLUNAS;

	WS_NCOLUMNS			DBMS_SQL.VARCHAR2_TABLE;
	WS_COLUNA_ANT			DBMS_SQL.VARCHAR2_TABLE;
	WS_PVCOLUMNS			DBMS_SQL.VARCHAR2_TABLE;
	WS_MFILTRO			DBMS_SQL.VARCHAR2_TABLE;
	WS_VCOL				DBMS_SQL.VARCHAR2_TABLE;
	WS_VCON				DBMS_SQL.VARCHAR2_TABLE;

	WS_DRILL			VARCHAR2(40);
	WS_ZEBRADO			VARCHAR2(20);
	WS_ZEBRADO_D		VARCHAR2(40);
	WS_QUERYOC			CLOB;
	WS_PIPE				CHAR(1);

	WS_POSX				VARCHAR(5);
	WS_POSY				VARCHAR(5);

	RET_COLUP			LONG;
	WS_LQUERY			NUMBER;
	WS_COUNTERID			NUMBER := 0;
	WS_COUNTER			NUMBER := 1;
	WS_CCOLUNA			NUMBER := 1;
	WS_XCOLUNA			NUMBER := 0;
	WS_CHCOR			NUMBER := 0;
	WS_BINDN			NUMBER := 0;
	WS_SCOL				NUMBER := 0;
	WS_CSPAN			NUMBER := 0;
	WS_XCOUNT			NUMBER := 0;
	WS_CTNULL			NUMBER := 0;
	WS_CTCOL			NUMBER := 0;

	WS_TEXTO			LONG;
	WS_TEXTOT			LONG;
	WS_NM_VAR			LONG;
	WS_CONTENT_ANT			LONG;
	WS_CONTENT			LONG;
	WS_COLUP			LONG;
	WS_COLUNA			LONG;
	WS_AGRUPADOR			LONG;
	WS_RP				LONG;
	WS_XATALHO			LONG;
	WS_ATALHO			LONG;
	WS_PARAMETROS			LONG;
	WS_AGRUPADOR_MAX    NUMBER;

	WS_ACESSO			EXCEPTION;
	WS_SEMQUERY			EXCEPTION;
	WS_SEMPERMISSAO			EXCEPTION;
	WS_PCURSOR			INTEGER;
	WS_CURSOR			INTEGER;
	WS_LINHAS			INTEGER;
	WS_QUERY_MONTADA		DBMS_SQL.VARCHAR2A;
	WS_QUERY_COUNT          DBMS_SQL.VARCHAR2A;
	WS_QUERY_PIVOT			LONG;
	WS_SQL				LONG;
	WS_SQL_PIVOT			LONG;
	
	
	WS_TITULO			VARCHAR2(150);
	
	WS_MODE				VARCHAR2(30);
	WS_IDCOL			VARCHAR2(120);
	WS_CLEARDRILL		VARCHAR2(120);
	WS_FIRSTID			CHAR(1);

	WS_VAZIO			BOOLEAN := TRUE;
	WS_NODATA       		EXCEPTION;
	WS_INVALIDO			EXCEPTION;
	
	WS_CLOSE_HTML			EXCEPTION;
	WS_MOUNT			EXCEPTION;
	WS_PARSEERR			EXCEPTION;

	WS_POSICAO			VARCHAR2(2000) := ' ';
	WS_DRILL_ATALHO		VARCHAR2(3000);
	WS_CTEMP			VARCHAR2(40);
	WS_TMP_JUMP			VARCHAR2(300);
	WS_JUMP				VARCHAR2(600);
	WS_SEM				VARCHAR2(40);
	WS_TITLE 			CLOB;
	WS_GOTOCOUNTER		NUMBER;
	
	WS_STEP             NUMBER;
	WS_STEPPER          NUMBER := 0;
	
	WS_LINHA            NUMBER := 0;
	WS_FIXED            VARCHAR2(40);
	WS_CT_TOP           NUMBER := 0;
	WS_TOP              NUMBER := 0;
	WS_TMP_CHECK        VARCHAR2(300);
	WS_CHECK            VARCHAR2(300);
	WS_ROW              NUMBER;
	WS_PIVOT            VARCHAR2(300);
    RET_COLGRP          VARCHAR2(2000);
	RET_COLTOT          VARCHAR2(2000);
	WS_TEMP_VALOR       NUMBER := 0;
    WS_TOTAL_LINHA      NUMBER := 0;
	WS_ACUMULADA_LINHA  NUMBER := 0;
	WS_LINHA_ACUMULADA  VARCHAR2(10);
	WS_TOTAL_ACUMULADO  VARCHAR2(10);
	
	WS_LIMITE_I         VARCHAR2(10);
	WS_LIMITE_F         VARCHAR2(10);
	WS_ISOLADO          VARCHAR2(60);
	WS_REPEAT           VARCHAR2(60) := 'show';
	WS_CAB_CROSS        VARCHAR2(4000) := 'N';
	WS_COD              VARCHAR2(200);
	WS_COD_AC           VARCHAR2(200);
	WS_SUBQUERY         VARCHAR2(600);
	WS_ORDEM            NUMBER;
	WS_COLOR            VARCHAR2(60);
	WS_SPACE            VARCHAR2(90);
	WS_SPACE_AT         VARCHAR2(90);
	WS_SELF             VARCHAR2(400);
	WS_COUNT            NUMBER;
	WS_COR              VARCHAR2(400);
	WS_BLINK_LINHA      VARCHAR2(4000) := 'N/A';
	WS_TPT              VARCHAR2(400);
	WS_ORDER            NUMBER;
	WS_FIX              VARCHAR2(80);
    WS_USUARIO          VARCHAR2(80);
	WS_ADMIN            VARCHAR2(10);

BEGIN

    WS_USUARIO := GBL.GETUSUARIO;
	WS_ADMIN   := GBL.GETNIVEL;

    WS_ORDEM  := PRM_ORDEM+1;
	WS_COUNTER := 1;
	FOR I IN (SELECT COLUMN_VALUE FROM TABLE(FUN.VPIPE((FUN.GETPROP(PRM_OBJID,'SUBQUERY'))))) LOOP
	    IF WS_COUNTER = WS_ORDEM THEN
		    WS_SUBQUERY := I.COLUMN_VALUE;
		END IF;
		WS_COUNTER := WS_COUNTER+1;
	END LOOP;

	WS_COUNTER := 1;
	LOOP
		IF WS_COUNTER = WS_ORDEM THEN
			EXIT;
		ELSE
			WS_SPACE := WS_SPACE;
			WS_SPACE_AT := WS_SPACE_AT;
		END IF;
	    WS_COUNTER := WS_COUNTER+1;
	END LOOP;

	WS_COR := FUN.GETPROP(PRM_OBJID, 'SUBQUERY-COR');

	BEGIN
	    SELECT COR INTO WS_COLOR FROM (SELECT NVL(COLUMN_VALUE, '#EFEFEF') COR, ROWNUM LINHA FROM TABLE(FUN.VPIPE(WS_COR))) WHERE LINHA = PRM_ORDEM;
	    IF INSTR(WS_COLOR, '#') > 1 THEN
		    WS_COLOR := SUBSTR(WS_COLOR, 2, LENGTH(WS_COLOR)-1);
		END IF;
	EXCEPTION WHEN OTHERS THEN
	    WS_COLOR := '#EFEFEF';
	END;

	HTP.P('<style>');
	HTP.P('table#'||PRM_OBJID||'trlc tbody tr.nivel'||WS_ORDEM||', table#'||PRM_OBJID||'c tbody tr.nivel'||WS_ORDEM||', div#'||PRM_OBJID||'trlheader table tbody tr.nivel'||WS_ORDEM||' { background-color: '||WS_COLOR||' !important; }');
	HTP.P('div#'||PRM_OBJID||'header table tbody tr.nivel'||WS_ORDEM||', div#'||PRM_OBJID||'trlfixed ul li.nivel'||WS_ORDEM||', div#'||PRM_OBJID||'fixed ul li.nivel'||WS_ORDEM||' { background-color: '||WS_COLOR||' !important; }'); 
	HTP.P('div#'||PRM_OBJID||'trlfixed ul li.nivel'||WS_ORDEM||', div#'||PRM_OBJID||'fixed ul li.nivel'||WS_ORDEM||', div#'||PRM_OBJID||'trlfixed ul li.nivel'||WS_ORDEM||' { text-indent: '||WS_ORDEM||'px; }');
	HTP.P('div#'||PRM_OBJID||'fixed ul li.nivel'||WS_ORDEM||', table#'||PRM_OBJID||'trlc tbody tr.nivel'||WS_ORDEM||' td:nth-child(2), table#'||PRM_OBJID||'c tbody tr.nivel'||WS_ORDEM||' td:nth-child(2) { text-indent: '||WS_ORDEM||'px; }');
	HTP.P('table#'||PRM_OBJID||'c tbody tr.nivel'||WS_ORDEM||' td:nth-child(3), div#'||PRM_OBJID||'trlheader table tbody tr.nivel'||WS_ORDEM||' td:nth-child(2), div#'||PRM_OBJID||'trlheader table tbody tr.nivel'||WS_ORDEM||' td:nth-child(3) { text-indent: '||WS_ORDEM||'px; }');
	HTP.P('div#'||PRM_OBJID||'header table tbody tr.nivel'||WS_ORDEM||' td:nth-child(2), div#'||PRM_OBJID||'header table tbody tr.nivel'||WS_ORDEM||' td:nth-child(3) { text-indent: '||WS_ORDEM||'px; }');
	IF FUN.GETPROP(PRM_OBJID,'FIXAR_TOT') = 'S' THEN
	    HTP.P('table#'||PRM_OBJID||'trlc tbody tr:last-child td { bottom: 0; position: sticky; }');
	END IF;
	
	HTP.P('</style>');

	SELECT CS_COLUNA INTO WS_COD FROM PONTO_AVALIACAO WHERE CD_PONTO = PRM_OBJID;
	SELECT COLUMN_VALUE INTO WS_COD FROM TABLE(FUN.VPIPE((WS_COD))) WHERE ROWNUM = 1;
	SELECT ST_COM_CODIGO INTO WS_COD FROM MICRO_COLUNA WHERE CD_COLUNA = WS_COD AND CD_MICRO_VISAO = PRM_MICRO_VISAO;

    WS_ZEBRADO := 'First';

    IF  NOT FUN.CHECK_USER(WS_USUARIO) OR NOT FUN.CHECK_NETWALL(WS_USUARIO) OR FUN.CHECK_SYS <> 'OPEN' THEN
	    IF  NOT FUN.CHECK_USER(WS_USUARIO) THEN
            INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - CHECK_USER', WS_USUARIO, 'ERRO');
            COMMIT;
		END IF;
	    IF  NOT FUN.CHECK_NETWALL(WS_USUARIO) THEN
            INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - CHECK_NETWALL', WS_USUARIO, 'ERRO');
            COMMIT;
		END IF;
	    IF  FUN.CHECK_SYS <> 'OPEN' THEN
            INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - CHECK_SYS', WS_USUARIO, 'ERRO');
            COMMIT;
		END IF;
        RAISE WS_ACESSO;
    END IF;

	WS_ISOLADO := FUN.GETPROP(PRM_OBJID, 'FILTRO');

	

	WS_COLUP     := PRM_COLUP;
	WS_COLUNA    := PRM_COLUNA;
	WS_AGRUPADOR := FUN.CONV_TEMPLATE(PRM_MICRO_VISAO, PRM_AGRUPADOR);
	WS_RP	     := 'GROUP';

	OPEN CRS_MICRO_VISAO;
	FETCH CRS_MICRO_VISAO INTO WS_MICRO_VISAO;
	CLOSE CRS_MICRO_VISAO;

	WS_TEXTO := PRM_PARAMETROS;

    WS_PARAMETROS := PRM_PARAMETROS;

	OPEN NC_COLUNAS;
	    LOOP
			FETCH NC_COLUNAS BULK COLLECT INTO RET_MCOL LIMIT 400;
			EXIT WHEN NC_COLUNAS%NOTFOUND;
	    END LOOP;
	CLOSE NC_COLUNAS;

	WS_COUNTER := 0;

	WS_SEM := 1;


	WS_SELF := PRM_SELF;

	IF INSTR(WS_SELF, '|') = 1 THEN
	    WS_SELF := SUBSTR(WS_SELF, 2 ,LENGTH(WS_SELF)-1);
	END IF;

	WS_SELF := REPLACE(WS_SELF, '||', '|');

    



	

	

    
    IF INSTR(WS_COLUNA, '|') > 0 THEN
	    WS_COLUNA := SUBSTR(WS_COLUNA, 0, LENGTH(WS_COLUNA)-1);
	END IF;


	WS_SQL := CORE.MONTA_QUERY_DIRECT(PRM_MICRO_VISAO, WS_COLUNA, WS_PARAMETROS, WS_RP, WS_COLUP, WS_QUERY_PIVOT, WS_QUERY_MONTADA, WS_LQUERY, WS_NCOLUMNS, WS_PVCOLUMNS, WS_AGRUPADOR, WS_MFILTRO, PRM_OBJID, FUN.GETPROP(PRM_OBJID,'SUBQUERY_ORDEM'), PRM_SCREEN => PRM_SCREEN, PRM_CROSS => 'N', PRM_CAB_CROSS => WS_CAB_CROSS, PRM_SELF => 'SUBQUERY_'||WS_SELF);

	



    INSERT INTO LOG_EVENTOS VALUES(SYSDATE, PRM_MICRO_VISAO||'/'||WS_COLUNA||'/->'||WS_SELF||'<-|'||WS_PARAMETROS||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR, WS_USUARIO, 'SUBQUERY', 'SUBQUERY', '01');

	WS_QUERYOC := '';
	WS_COUNTER := 0;
	WS_GOTOCOUNTER := 0;

	IF WS_ADMIN = 'A' THEN 
		LOOP
	    	WS_COUNTER := WS_COUNTER + 1;
	    	IF  WS_COUNTER > WS_QUERY_MONTADA.COUNT THEN
	    		EXIT;
	    	END IF;
	    	WS_QUERYOC := WS_QUERYOC||WS_QUERY_MONTADA(WS_COUNTER);
			HTP.P(WS_QUERY_MONTADA(WS_COUNTER));
		END LOOP;
	END IF;	

	/*IF WS_SQL = 'Sem Query' THEN
	   RAISE WS_SEMQUERY;
	END IF;*/

	WS_SQL_PIVOT := WS_QUERY_PIVOT;


	WS_COUNTER   := 0;
	WS_COUNTERID := 1;
	WS_CCOLUNA   := 0;
    WS_STEP := 0;

	WS_REPEAT := 'show';
	WS_FIRSTID := 'Y';
    WS_AGRUPADOR_MAX :=0;


	WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE( C => WS_CURSOR, STATEMENT => WS_QUERY_MONTADA, LB => 1, UB => WS_LQUERY, LFFLG => TRUE, LANGUAGE_FLAG => DBMS_SQL.NATIVE );

	

	WS_SQL := CORE.BIND_DIRECT(REPLACE(WS_PARAMETROS||'|'||WS_SELF, '||', '|'), WS_CURSOR, '', PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN);

	WS_COUNTER := 0;
	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
	    	EXIT;
	    END IF;
	    DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, RET_COLUNA, 2000);
	END LOOP;
	WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);

	WS_COUNTER := 0;
	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > WS_NCOLUMNS.COUNT-2 THEN
		EXIT;
	    END IF;

	    WS_CCOLUNA := 1;
	    LOOP
		IF  WS_CCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
		    EXIT;
		END IF;
		WS_CCOLUNA := WS_CCOLUNA + 1;
	    END LOOP;

	    IF  RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' THEN
	        WS_VCOL(WS_COUNTER) := RET_MCOL(WS_CCOLUNA).CD_COLUNA;
	        WS_VCON(WS_COUNTER) := 'First';
	    END IF;

	    WS_COLUNA_ANT(WS_COUNTER) := 'First';
	END LOOP;

	LOOP
	    WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_CURSOR);
	    IF  WS_LINHAS = 1 THEN
		    WS_VAZIO := FALSE;
	    ELSE
            IF  WS_VAZIO = TRUE THEN
	            DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
      		    RAISE WS_NODATA;
        	END IF;
        	EXIT;
	    END IF;

		WS_CT_TOP := WS_CT_TOP + 1;
        IF  WS_TOP <> 0 AND WS_CT_TOP > WS_TOP THEN
            EXIT;
        END IF;

		IF  WS_ZEBRADO IN ('First','Escuro') THEN
			WS_ZEBRADO   := 'Claro';
			WS_ZEBRADO_D := 'Distinto_claro';
		ELSE
			WS_ZEBRADO   := 'Escuro';
			WS_ZEBRADO_D := 'Distinto_escuro';
		END IF;

	    WS_COUNTER := 0;
	    WS_CCOLUNA := 0;
	    WS_CHCOR   := 0;
	    WS_CTNULL  := 0;
	    WS_CTCOL   := 0;

	  LOOP

		WS_COUNTER := WS_COUNTER + 1;
		IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
		    EXIT;
		END IF;

		WS_XCOLUNA := 1;
		LOOP
		    IF  WS_XCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_XCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
				EXIT;
		    END IF;
		    WS_XCOLUNA := WS_XCOLUNA + 1;
		END LOOP;

		WS_CCOLUNA := WS_CCOLUNA + 1;
		DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_CCOLUNA, RET_COLUNA);

		IF  RET_MCOL(WS_XCOLUNA).ST_AGRUPADOR = 'SEM' THEN
		    WS_CTCOL  := WS_CTCOL + 1;
		END IF;
		IF  NVL(RET_COLUNA,'%*') = '%*' AND RET_MCOL(WS_XCOLUNA).ST_AGRUPADOR = 'SEM' THEN
		    WS_CTNULL := WS_CTNULL + 1;
			RET_COLGRP := 1;
		END IF;

	  END LOOP;

	    WS_XATALHO := '';
	    WS_PIPE    := '';
	    WS_BINDN := 1;
	    
		IF  WS_BINDN = 1 OR WS_NCOLUMNS(WS_BINDN) <> WS_NCOLUMNS(WS_BINDN-1) THEN
		    DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_BINDN, RET_COLUNA);
		    WS_VCON(WS_BINDN) := RET_COLUNA;
		    IF  NVL(WS_VCON(WS_BINDN),'%*') <> '%*' THEN
		        WS_XATALHO := WS_XATALHO||WS_PIPE;
			WS_XATALHO := TRIM(WS_XATALHO)||WS_VCOL(WS_BINDN)||'|'||WS_VCON(WS_BINDN);
			WS_PIPE    := '|';
		    END IF;
		END IF;
		
	    

		DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_NCOLUMNS.COUNT-1, RET_COLGRP);
		DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_NCOLUMNS.COUNT, RET_COLTOT);
		WS_LINHA := WS_LINHA+1;
		
		WS_FIXED := NVL(FUN.GETPROP(PRM_OBJID, 'FIXED-N'), '9999')+1;
		IF LENGTH(FUN.GETPROP(PRM_OBJID,'TOTAL_GERAL_TEXTO')) > 0 AND WS_FIXED > 0 THEN
		    WS_FIXED := 999;
		END IF;


		IF(WS_ZEBRADO = 'Escuro') THEN
			HTP.P('<tr data-tipo="'||WS_ZEBRADO||'" class="es sub nivel'||WS_ORDEM||'">');
		ELSE
			HTP.P('<tr data-tipo="'||WS_ZEBRADO||'" class="cl sub nivel'||WS_ORDEM||'">');
		END IF;

		IF(LENGTH(WS_TMP_JUMP) > 5) THEN
		    WS_CHECK := WS_TMP_CHECK;
		END IF;

		WS_DRILL_ATALHO := REPLACE('|'||TRIM(WS_XATALHO),'||','|');
		IF(INSTR(WS_DRILL_ATALHO, '|', 1, 1) = 1) THEN
		  WS_DRILL_ATALHO := SUBSTR(WS_DRILL_ATALHO,2,LENGTH(WS_DRILL_ATALHO));
		END IF;

		WS_JUMP := WS_TMP_JUMP;

		IF(LENGTH(WS_SUBQUERY) > 0) THEN
		    WS_JUMP := 'seta';
		ELSE
		    WS_JUMP := 'setadown';
		END IF;

		


		
		IF WS_FIXED > 1 THEN
			WS_FIX   := 'fixsub';
			WS_FIXED := WS_FIXED-1;
		ELSE
			WS_FIX   := '';
		END IF;


		IF RET_COLGRP = 0 THEN
		    HTP.P('<td '||WS_CHECK||' class="'||WS_JUMP||' '||WS_FIX||'" data-ordem="'||WS_ORDEM||'" data-valor="'||REPLACE(WS_PARAMETROS||'|'||WS_DRILL_ATALHO, '||', '|')||'" data-self="'||WS_DRILL_ATALHO||'"  data-subquery="'||WS_SUBQUERY||'"></td>');
		END IF;

	    WS_COUNTER := 0;
		WS_LIMITE_I := FUN.GETPROP(PRM_OBJID,'COLUNA_INICIAL');
        WS_LIMITE_F := FUN.GETPROP(PRM_OBJID,'COLUNA_FINAL');
        WS_TOTAL_ACUMULADO := FUN.GETPROP(PRM_OBJID,'TOTAL_ACUMULADO');
		WS_LINHA_ACUMULADA := FUN.GETPROP(PRM_OBJID,'LINHA_ACUMULADA');
	LOOP
		WS_COUNTER := WS_COUNTER + 1;

		IF FUN.GETPROP(PRM_OBJID,'NO_TUP') <> 'S' OR WS_PVCOLUMNS.COUNT = 0 THEN
			IF  WS_COUNTER > WS_NCOLUMNS.COUNT-2 THEN
				EXIT;
			END IF;
		ELSE
		  IF  WS_COUNTER > WS_NCOLUMNS.COUNT-2 THEN
				EXIT;
			END IF;
		END IF;

		BEGIN
		    IF(WS_COUNTER) < WS_STEP-(WS_STEPPER) THEN
		        WS_ATALHO := WS_MFILTRO(WS_COUNTER+1);
			ELSE
			    WS_ATALHO := '';
			END IF;
		EXCEPTION
		    WHEN OTHERS THEN
			WS_ATALHO := '';
		END;

		WS_CCOLUNA := 1;
  LOOP

	  IF  WS_CCOLUNA > RET_MCOL.COUNT THEN
          WS_CCOLUNA := WS_CCOLUNA - 1;
          EXIT;
      END IF;

      IF RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER)  THEN
           EXIT;
      END IF;


      WS_CCOLUNA := WS_CCOLUNA + 1;

  END LOOP;

		DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_COUNTER, RET_COLUNA);

		RET_COLUNA := REPLACE(RET_COLUNA,'"','*');
		RET_COLUNA := REPLACE(RET_COLUNA,'/',' ');

		IF  WS_FIRSTID = 'Y' THEN
		    WS_IDCOL := ' id="'||PRM_OBJID||WS_COUNTER||'l" ';
		ELSE
		    WS_IDCOL := '';
		END IF;

		WS_DRILL_ATALHO := REPLACE(TRIM(WS_ATALHO)||'|'||TRIM(WS_XATALHO),'||','|');
		IF(INSTR(WS_DRILL_ATALHO, '|', 1, 1) = 1) THEN
		  WS_DRILL_ATALHO := SUBSTR(WS_DRILL_ATALHO,2,LENGTH(WS_DRILL_ATALHO));
		END IF;

		





		IF(LENGTH(WS_JUMP) > 1) THEN
		  WS_JUMP := 'style="'||WS_JUMP||'"';
		END IF;
		
		IF WS_FIXED > 1 THEN
			WS_FIX   := 'fixsub';
			WS_FIXED := WS_FIXED-1;
		ELSE
			WS_FIX   := '';
		END IF;


		IF(RTRIM(RET_MCOL(WS_CCOLUNA).ST_INVISIVEL) <> 'S') THEN
			IF(RTRIM(RET_MCOL(WS_CCOLUNA).ST_ALINHAMENTO) = 'RIGHT') THEN
				WS_JUMP := WS_JUMP||' class="dir"';
			END IF;

			IF(RTRIM(RET_MCOL(WS_CCOLUNA).ST_ALINHAMENTO) = 'CENTER') THEN
				WS_JUMP := WS_JUMP||' class="cen"';
			END IF;

			IF RET_MCOL(WS_CCOLUNA).ST_COM_CODIGO = 'N' AND RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' AND RET_MCOL(WS_CCOLUNA).CD_LIGACAO <> 'SEM' THEN

				IF LENGTH(WS_REPEAT) = 4 THEN
		            WS_REPEAT := 'hidden';
		        ELSE
		            WS_REPEAT := 'show';
		        END IF;
			ELSIF RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' THEN
				WS_JUMP := '';
			END IF;
		ELSE
			WS_JUMP := WS_JUMP||' class="no_font"';
		END IF;

		IF LENGTH(TRIM(WS_ATALHO)) > 0 AND WS_CT_TOP = 1 THEN
		    WS_PIVOT := 'data-p="'||TRIM(WS_ATALHO)||'" ';
		ELSE
		    WS_PIVOT := '';
		END IF;
        
		

		IF  WS_LINHA_ACUMULADA = 'S' AND RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR <> 'SEM' AND WS_COUNTER < WS_NCOLUMNS.COUNT AND RET_COLGRP = 0  THEN

			IF  WS_COUNTER > WS_LIMITE_I AND WS_COUNTER < (WS_NCOLUMNS.COUNT)-WS_LIMITE_F THEN
				BEGIN
					WS_TEMP_VALOR := TO_NUMBER(NVL(RET_COLUNA, '0'));
				EXCEPTION WHEN OTHERS THEN
				    WS_TEMP_VALOR := 0;
				END;

				WS_ACUMULADA_LINHA := WS_ACUMULADA_LINHA + WS_TEMP_VALOR;
				WS_CONTENT     := WS_ACUMULADA_LINHA;

			ELSE
			    WS_CONTENT := RET_COLUNA;
			END IF;
		ELSE
		    WS_CONTENT := RET_COLUNA;
		END IF;

		

 
	 SELECT ST_COM_CODIGO INTO WS_COD_AC FROM MICRO_COLUNA WHERE CD_MICRO_VISAO = PRM_MICRO_VISAO AND CD_COLUNA = RET_MCOL(WS_CCOLUNA).CD_COLUNA;
	 
        --FUN.GETPROP(PRM_OBJID,'SO_TOT', PRM_TIPO => 'CONSULTA') <> 'S' OR RET_COLTOT = 1 OR PRM_DRILL
	    --htp.p('<td style="display: none;">'||WS_CONTENT||' - '||WS_REPEAT||' - '||FUN.GETPROP(PRM_OBJID,'SO_TOT', PRM_TIPO => 'CONSULTA')||' - '||RET_COLTOT||' - '||PRM_DRILL||'</td>');
	   
		IF  RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' AND WS_CONTENT = WS_COLUNA_ANT(WS_COUNTER) THEN
			
			IF LENGTH(WS_REPEAT) = 4 THEN
			    HTP.P('<td class="'||WS_FIX||'" '||WS_IDCOL||' data-i="'||WS_COUNTER||'">'||FCL.FPDATA((WS_CTNULL - WS_CTCOL),0,'','')||FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA), PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN)||'</td>');
			END IF;
		ELSE
		    IF RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' THEN
				IF LENGTH(WS_REPEAT) = 4 THEN
					IF WS_COD = 'S' THEN
					    
					    HTP.P('<td '||WS_IDCOL||' class="'||WS_FIX||'" data-i="'||WS_COUNTER||'">'||FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA),PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN)||'</td>');
					ELSE
					    IF WS_COUNTER = 1 THEN

							IF WS_COD_AC <> 'S' THEN
				            	HTP.P('<td '||WS_IDCOL||' class="'||WS_FIX||'" data-i="'||WS_COUNTER||'">'||FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA),PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN)||'</td>');

							END IF;
						ELSE
						    HTP.P('<td '||WS_IDCOL||' class="'||WS_FIX||'" data-i="'||WS_COUNTER||'">'||FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA),PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN)||'</td>');

						END IF;
					END IF;
				
				END IF;
			ELSE
		        IF(RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR IN ('PSM','PCT') AND RET_COLGRP <> 0) OR (RET_MCOL(WS_CCOLUNA).ST_GERA_REL = 'N' AND RET_COLGRP <> 0) THEN
		            WS_CONTENT := ' ';
		        END IF;
					IF FUN.GETPROP(PRM_OBJID,'SO_TOT', PRM_TIPO => 'CONSULTA') <> 'S' OR RET_COLTOT = 1 OR nvl(PRM_DRILL, 'C') = 'C' THEN

						HTP.P('<td data-i="'||WS_COUNTER||'" '||WS_IDCOL||FUN.CHECK_BLINK_TOTAL(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT, '', PRM_SCREEN)||' '||WS_JUMP||' '||WS_PIVOT||'>');

							IF RET_COLGRP <> 0 THEN 
								IF RET_COLTOT <> 1 THEN
								
									HTP.PRN(FUN.UM(RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_MICRO_VISAO, FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA), PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN)));
									
								ELSE
									HTP.PRN(FUN.UM(RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_MICRO_VISAO, FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA), PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN)));
								END IF;
							ELSE
								HTP.PRN(FUN.UM(RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_MICRO_VISAO, FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA), PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN)));
							END IF;


							IF(FUN.RET_SINAL(PRM_OBJID,RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT) <> 'nodata') THEN
								HTP.P(FUN.RET_SINAL(PRM_OBJID,RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT));
								
							END IF;

						HTP.P('</td>');

					END IF;
			END IF;


		IF LENGTH(FUN.CHECK_BLINK_LINHA(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_LINHA, RET_COLUNA, PRM_SCREEN)) > 7 AND RET_COLGRP = 0 THEN
		    WS_BLINK_LINHA := FUN.CHECK_BLINK_LINHA(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_LINHA, RET_COLUNA, PRM_SCREEN);
		END IF;

        

		END IF;
		WS_JUMP := '';
		WS_CHECK := '';
        
                


		WS_COLUNA_ANT(WS_COUNTER) := RET_COLUNA;
	    END LOOP;

		IF WS_BLINK_LINHA <> 'N/A' THEN HTP.P(WS_BLINK_LINHA); END IF;
	    WS_BLINK_LINHA := 'N/A';

	    WS_FIRSTID := 'N';

	    HTP.TABLEROWCLOSE;
		WS_ACUMULADA_LINHA := 0;
		WS_TOTAL_LINHA := 0;

	END LOOP;
	WS_TOTAL_LINHA := 0;
	WS_ACUMULADA_LINHA := 0;
	DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
	WS_TEXTOT := '';
	WS_PIPE   := '';
	WS_COUNTER := 0;

	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
		  EXIT;
	    END IF;

	    WS_CCOLUNA := 1;
	    LOOP
		IF  WS_CCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
		    EXIT;
		END IF;
		WS_CCOLUNA := WS_CCOLUNA + 1;
	    END LOOP;

	    IF  RET_MCOL(WS_CCOLUNA).CD_LIGACAO <> 'SEM' AND RET_MCOL(WS_CCOLUNA).ST_COM_CODIGO = 'S' THEN
		    WS_TEXTOT := WS_TEXTOT||WS_PIPE||'2';
		    WS_PIPE   := '|';
		    WS_COUNTER := WS_COUNTER + 1;
	    ELSE
		    WS_TEXTOT := WS_TEXTOT||WS_PIPE||'1';
		    WS_PIPE   := '|';
	    END IF;
	END LOOP;

EXCEPTION
	WHEN OTHERS	     THEN
	    INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SUBQUERY', WS_USUARIO, 'ERRO');
        COMMIT;
END SUBQUERY;

PROCEDURE CONSULTA_DADOS ( PRM_OBJID         VARCHAR2 DEFAULT NULL,
                           PRM_SCREEN        VARCHAR2 DEFAULT NULL,
						   PRM_MICRO_VISAO   VARCHAR2 DEFAULT NULL, 
						   PRM_COLUNA        VARCHAR2 DEFAULT NULL,
						   PRM_PARAMETROS    VARCHAR2 DEFAULT NULL, 
						   PRM_RP            VARCHAR2 DEFAULT NULL, 
						   PRM_COLUP         VARCHAR2 DEFAULT NULL,
						   PRM_AGRUPADOR     VARCHAR2 DEFAULT NULL,
						   PRM_SELF          VARCHAR2 DEFAULT NULL ) AS

    TYPE WS_TMCOLUNAS IS TABLE OF MICRO_COLUNA%ROWTYPE INDEX BY PLS_INTEGER;
	
	CURSOR NC_COLUNAS IS SELECT * FROM MICRO_COLUNA WHERE CD_MICRO_VISAO = PRM_MICRO_VISAO;

	WS_FIRSTID		 CHAR(1);
    WS_LINHAS        INTEGER;
	WS_CURSOR		 INTEGER;
	WS_VAZIO         BOOLEAN;
	WS_LINHA_AC      VARCHAR2(10);
	WS_SAIDA         VARCHAR2(10) := 'S';
	WS_LIMITE_I      VARCHAR2(10);
	WS_LIMITE_F      VARCHAR2(10);
	WS_TOTAL_AC      VARCHAR2(10);
	WS_REPEAT        VARCHAR2(60) := 'show';
	WS_USUARIO       VARCHAR2(80);
	WS_ALINHAMENTO   VARCHAR2(80);
	WS_OBJID		 VARCHAR2(120);
	WS_IDCOL		 VARCHAR2(120);
	WS_ZEBRADO       VARCHAR2(120);
	WS_ZEBRADO_D     VARCHAR2(120);
	WS_PIPE          VARCHAR2(200);
	WS_COD_COLUNA    VARCHAR2(200);
	WS_CALCULADA_N   VARCHAR2(200);
    WS_CALCULADA_M   VARCHAR2(200);
	WS_HINT          VARCHAR2(300);
	WS_PIVOT         VARCHAR2(300);
	WS_CHECK         VARCHAR2(300);
	WS_TMP_CHECK     VARCHAR2(300);
	WS_TMP_JUMP		 VARCHAR2(300);
	WS_ORDEM         VARCHAR2(400);
	WS_NM_VAR_AL     VARCHAR2(400);
	WS_CD_COLUNA     VARCHAR2(400);
	WS_JUMP			 VARCHAR2(600);
	WS_SUBQUERY      VARCHAR2(600);
	WS_CONTEUDO_ANT  VARCHAR2(800);
	WS_CALCULADA     VARCHAR2(800);
	RET_COLGRP       VARCHAR2(2000);
	RET_COLTOT       VARCHAR2(2000);
	WS_DRILL_ATALHO  VARCHAR2(3000);
	WS_BINDS         VARCHAR2(3000);
	RET_COLUNA		 VARCHAR2(4000);
	WS_TEXTO_AL      VARCHAR2(4000);
	WS_PIVOT_COLUNA  VARCHAR2(4000);
	WS_CAB_CROSS     VARCHAR2(4000);
	WS_BLINK_LINHA   VARCHAR2(4000) := 'N/A';
	WS_ATALHO        CLOB;
	WS_XATALHO       CLOB;
	WS_EXCEL         CLOB;
	WS_CONTENT_ANT	 CLOB;
	WS_CONTENT		 LONG;
	WS_PARAMETROS	 LONG;
	WS_SQL			 LONG;
	WS_QUERY_PIVOT   LONG;
	WS_COUNT         NUMBER := 0;
	WS_SCOL			 NUMBER := 0;
	WS_TEMP_VALOR    NUMBER := 0;
	WS_TEMP_VALOR2   NUMBER := 0;
	WS_TOTAL_LINHA   NUMBER := 0;
	WS_AC_LINHA      NUMBER := 0;
	WS_COUNTOR       NUMBER;
	WS_COUNTV        NUMBER;
	WS_STEP          NUMBER;
	WS_STEPPER       NUMBER;
	WS_TOP           NUMBER;
	WS_CT_TOP        NUMBER;
	WS_COUNTER       NUMBER;
	WS_CCOLUNA       NUMBER;
	WS_CHCOR         NUMBER;
	WS_CTNULL        NUMBER;
	WS_CTCOL         NUMBER;
	WS_XCOLUNA       NUMBER;
	WS_BINDN         NUMBER;
	WS_LINHA         NUMBER;
	WS_LINHA_COL     NUMBER;
	WS_AMOSTRA       NUMBER;
	WS_LQUERY		 NUMBER;
	DIMENSAO_SOMA    NUMBER := 1;
	WS_NODATA        EXCEPTION;
	WS_COLUNA_ANT    DBMS_SQL.VARCHAR2_TABLE;
	WS_ARR_ATUAL     DBMS_SQL.VARCHAR2_TABLE;
	WS_ARR_ANTERIOR  DBMS_SQL.VARCHAR2_TABLE;
	WS_VCOL			 DBMS_SQL.VARCHAR2_TABLE;
	WS_VCON			 DBMS_SQL.VARCHAR2_TABLE;
	WS_NCOLUMNS	     DBMS_SQL.VARCHAR2_TABLE;
	WS_MFILTRO	     DBMS_SQL.VARCHAR2_TABLE;
	WS_ARRAY_ATUAL   DBMS_SQL.VARCHAR2_TABLE;
	WS_CLASS_ATUAL   DBMS_SQL.VARCHAR2_TABLE;
	WS_PVCOLUMNS     DBMS_SQL.VARCHAR2_TABLE;
	WS_QUERY_MONTADA DBMS_SQL.VARCHAR2A;
	WS_QUERY_COUNT   DBMS_SQL.VARCHAR2A;

	RET_MCOL         WS_TMCOLUNAS;

BEGIN

    WS_USUARIO := GBL.GETUSUARIO;

    OPEN NC_COLUNAS;
	LOOP
	    FETCH NC_COLUNAS BULK COLLECT INTO RET_MCOL LIMIT 400;
	    EXIT WHEN NC_COLUNAS%NOTFOUND;
	END LOOP;
	CLOSE NC_COLUNAS;

    WS_ORDEM := '';
	WS_COUNTOR := 0;
	SELECT COUNT(*) INTO WS_COUNTOR FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJID AND CD_PROP = 'ORDEM' AND OWNER = WS_USUARIO;
	IF WS_COUNTOR = 1 THEN
	    SELECT UPPER(PROPRIEDADE) INTO WS_ORDEM FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJID AND CD_PROP = 'ORDEM' AND OWNER = WS_USUARIO;
	ELSE
	    SELECT COUNT(*) INTO WS_COUNTOR FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJID AND CD_PROP = 'ORDEM' AND OWNER = 'DWU';
	    IF WS_COUNTOR = 1 THEN
	        SELECT UPPER(PROPRIEDADE) INTO WS_ORDEM FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJID AND CD_PROP = 'ORDEM' AND OWNER = 'DWU';
	    END IF;
	END IF;


    WS_SQL := CORE.MONTA_QUERY_DIRECT(PRM_MICRO_VISAO, PRM_COLUNA, PRM_PARAMETROS, PRM_RP, PRM_COLUP, WS_QUERY_PIVOT, WS_QUERY_MONTADA, WS_LQUERY, WS_NCOLUMNS, WS_PVCOLUMNS, PRM_AGRUPADOR, WS_MFILTRO, PRM_OBJID, WS_ORDEM, PRM_SCREEN => PRM_SCREEN, PRM_CROSS => 'N', PRM_CAB_CROSS => WS_CAB_CROSS, PRM_SELF => PRM_SELF);

	WS_COUNTER := 0;

    







	
	WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE( C => WS_CURSOR, STATEMENT => WS_QUERY_MONTADA, LB => 1, UB => WS_LQUERY, LFFLG => TRUE, LANGUAGE_FLAG => DBMS_SQL.NATIVE );


	WS_BINDS := CORE.BIND_DIRECT(WS_PARAMETROS, WS_CURSOR, '', PRM_OBJID, PRM_MICRO_VISAO, PRM_SCREEN);
		
    WS_BINDS := REPLACE(WS_BINDS, 'Binds Carregadas=|', '');
	
	

		WS_COUNTER := 0;
	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
	    	EXIT;
	    END IF;
	    DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, RET_COLUNA, 2000);
	END LOOP;
	WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);

	WS_COUNTER := 0;
	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > WS_NCOLUMNS.COUNT-2 THEN
		EXIT;
	    END IF;

	    WS_CCOLUNA := 1;
	    LOOP
		IF  WS_CCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
		    EXIT;
		END IF;
		WS_CCOLUNA := WS_CCOLUNA + 1;
	    END LOOP;

	    IF  RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' THEN
	        WS_VCOL(WS_COUNTER) := RET_MCOL(WS_CCOLUNA).CD_COLUNA;
	        WS_VCON(WS_COUNTER) := 'First';
	    END IF;

	    WS_COLUNA_ANT(WS_COUNTER) := 'First';
	END LOOP;
	

	WS_COUNTER := 0;
	
	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
	    	EXIT;
	    END IF;
	    DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, RET_COLUNA, 2000);
	END LOOP;
	WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);
	
	

    LOOP
	    WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_CURSOR);
	    IF  WS_LINHAS = 1 THEN
		    WS_VAZIO := FALSE;
	    ELSE
            IF  WS_VAZIO = TRUE THEN
	            DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
      		    RAISE WS_NODATA;
        	END IF;
        	EXIT;
	    END IF;
		
		
		WS_CT_TOP := WS_CT_TOP + 1;
        IF  WS_TOP <> 0 AND WS_CT_TOP > WS_TOP THEN
            EXIT;
        END IF;

		IF  WS_ZEBRADO IN ('First','Escuro') THEN
			WS_ZEBRADO   := 'Claro';
			WS_ZEBRADO_D := 'Distinto_claro';
		ELSE
			WS_ZEBRADO   := 'Escuro';
			WS_ZEBRADO_D := 'Distinto_escuro';
		END IF;

	    WS_COUNTER := 0;
	    WS_CCOLUNA := 0;
	    WS_CHCOR   := 0;
	    WS_CTNULL  := 0;
	    WS_CTCOL   := 0;

	    LOOP

			WS_COUNTER := WS_COUNTER + 1;
			IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
				EXIT;
			END IF;

			WS_XCOLUNA := 1;
			LOOP
				IF  WS_XCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_XCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
					EXIT;
				END IF;
				WS_XCOLUNA := WS_XCOLUNA + 1;
			END LOOP;

			WS_CCOLUNA := WS_CCOLUNA + 1;
			DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_CCOLUNA, RET_COLUNA);


			IF  RET_MCOL(WS_XCOLUNA).ST_AGRUPADOR = 'SEM' THEN
				WS_CTCOL  := WS_CTCOL + 1;
			END IF;
			IF  NVL(RET_COLUNA,'%*') = '%*' AND RET_MCOL(WS_XCOLUNA).ST_AGRUPADOR = 'SEM' THEN
				WS_CTNULL := WS_CTNULL + 1;
				WS_CHCOR := 1;
			END IF;

	    END LOOP;

	    WS_XATALHO := '';
	    WS_PIPE    := '';
	    WS_BINDN := WS_VCOL.FIRST;
	    WHILE WS_BINDN IS NOT NULL LOOP
		IF  WS_BINDN = 1 OR WS_NCOLUMNS(WS_BINDN) <> WS_NCOLUMNS(WS_BINDN-1) THEN
		    DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_BINDN, RET_COLUNA);
		    WS_VCON(WS_BINDN) := RET_COLUNA;
		    IF  NVL(WS_VCON(WS_BINDN),'%*') <> '%*' THEN
		        WS_XATALHO := WS_XATALHO||WS_PIPE;
			WS_XATALHO := TRIM(WS_XATALHO)||WS_VCOL(WS_BINDN)||'|'||WS_VCON(WS_BINDN);
			WS_PIPE    := '|';
		    END IF;
		END IF;
		WS_BINDN := WS_VCOL.NEXT(WS_BINDN);
	    END LOOP;


		DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_NCOLUMNS.COUNT-1, RET_COLGRP);
		DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_NCOLUMNS.COUNT, RET_COLTOT);

		WS_LINHA := WS_LINHA+1;
		WS_LINHA_COL := WS_LINHA_COL+1;

		
        
        WS_AMOSTRA := TO_NUMBER(FUN.GETPROP(PRM_OBJID,'AMOSTRA'));
        
        IF (WS_LINHA > WS_AMOSTRA AND WS_AMOSTRA <> 0) THEN
			EXIT;
		END IF;


			IF RET_COLGRP = 0 THEN
			    IF(WS_ZEBRADO = 'Escuro') THEN
				    IF WS_SAIDA <> 'O' THEN
				        HTP.P('<tr class="es">');
				    END IF;
				    IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
				        FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '<Row>', '', '');
				    END IF;
				ELSE
				    IF WS_SAIDA <> 'O' THEN
				        HTP.P('<tr class="cl">');
					END IF;
					IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
				        FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '<Row>', '', '');
				    END IF;
				END IF;
			ELSE
				
				IF WS_SAIDA <> 'O' THEN
					IF RET_COLTOT = 1 THEN
						HTP.P('<tr class="total geral">');
					ELSE
					    IF FUN.GETPROP(PRM_OBJID,'SO_TOT') <> 'S' THEN
						    HTP.P('<tr class="total normal">');
						END IF;
					END IF;
				END IF;
				
				IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
					FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '<Row>', '', '');
				END IF;
				
				IF  WS_ZEBRADO IN ('First','Escuro') THEN
					WS_ZEBRADO   := 'Claro';
					WS_ZEBRADO_D := 'Distinto_claro';
				ELSE
					WS_ZEBRADO   := 'Escuro';
					WS_ZEBRADO_D := 'Distinto_escuro';
				END IF;
				
				WS_LINHA_COL := 0;

			END IF;


			IF LENGTH(WS_TMP_JUMP) > 5 THEN
			    WS_CHECK := WS_TMP_CHECK;
			END IF;

			WS_DRILL_ATALHO := REPLACE('|'||TRIM(WS_XATALHO),'||','|');
			
			IF(INSTR(WS_DRILL_ATALHO, '|', 1, 1) = 1) THEN
			    WS_DRILL_ATALHO := SUBSTR(WS_DRILL_ATALHO,2,LENGTH(WS_DRILL_ATALHO));
			END IF;

			WS_JUMP := WS_TMP_JUMP;

			IF FUN.VERIFICA_POST(PRM_OBJID, WS_DRILL_ATALHO) THEN
				WS_JUMP := WS_JUMP||' flag';
			END IF;

			WS_COD_COLUNA := RET_COLUNA;

			IF RET_COLGRP = 0 THEN
			    IF WS_SAIDA <> 'O' THEN
				    HTP.P('<td '||WS_CHECK||' title="'||RET_COLUNA||'" class="'||WS_JUMP||'" data-subquery="'||WS_SUBQUERY||'" data-ordem="1" data-valor="'||WS_DRILL_ATALHO||'"></td>');
				END IF;
			ELSE
			    IF RET_COLTOT = 1 THEN
			        IF WS_SAIDA <> 'O' THEN
					    HTP.P('<td style="text-align: right;" colspan="'||DIMENSAO_SOMA||'" data-valor="'||WS_DRILL_ATALHO||'">'||FUN.GETPROP(PRM_OBJID,'TOTAL_GERAL_TEXTO')||'</td>');
					END IF;
				ELSE
			        IF WS_SAIDA <> 'O' THEN
					    
						IF FUN.GETPROP(PRM_OBJID,'SO_TOT') <> 'S' THEN
							HTP.P('<td data-valor="'||WS_DRILL_ATALHO||'"></td>');
						END IF;
					END IF;
				END IF;
			END IF;

		    WS_COUNTER := 0;
			WS_LIMITE_I := FUN.GETPROP(PRM_OBJID,'COLUNA_INICIAL');
	        WS_LIMITE_F := FUN.GETPROP(PRM_OBJID,'COLUNA_FINAL');
	        WS_TOTAL_AC := FUN.GETPROP(PRM_OBJID,'TOTAL_ACUMULADO');
			WS_LINHA_AC := FUN.GETPROP(PRM_OBJID,'LINHA_ACUMULADA');
			

			LOOP
				WS_COUNTER := WS_COUNTER + 1;

				IF FUN.GETPROP(PRM_OBJID,'NO_TUP') <> 'S' OR WS_PVCOLUMNS.COUNT = 0 THEN
					IF  WS_COUNTER > WS_NCOLUMNS.COUNT-2 THEN
						EXIT;
					END IF;
				ELSE
				  IF  WS_COUNTER > WS_NCOLUMNS.COUNT-2 THEN
						EXIT;
					END IF;
				END IF;
				BEGIN
				    IF(WS_COUNTER) < WS_STEP-WS_STEPPER THEN
				        WS_ATALHO := WS_MFILTRO(WS_COUNTER+1);
					ELSE
					    WS_ATALHO := '';
					END IF;
				EXCEPTION
				    WHEN OTHERS THEN
					WS_ATALHO := '';
				END;

				WS_CCOLUNA := 1;
				  
				LOOP
				

					IF  WS_CCOLUNA > RET_MCOL.COUNT THEN
				        WS_CCOLUNA := WS_CCOLUNA - 1;
				        EXIT;
				    END IF;

				    IF RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER)  THEN
				        EXIT;
				    END IF;

				    WS_CCOLUNA := WS_CCOLUNA + 1;

				END LOOP;
				
		        DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_COUNTER, RET_COLUNA);

				RET_COLUNA := REPLACE(RET_COLUNA,'"','*');
				RET_COLUNA := REPLACE(RET_COLUNA,'/',' ');

				WS_CONTENT := RET_COLUNA;    

				BEGIN
				
					IF WS_LINHA > 1 THEN
						IF TRIM(RET_COLUNA) = TRIM(WS_ARR_ANTERIOR(WS_COUNTER)) AND FUN.GETPROP(PRM_OBJID,'NAO_REPETIR') = 'S' AND RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' THEN
							WS_CONTENT := '';
						END IF;
					END IF;
				EXCEPTION WHEN OTHERS THEN
				    HTP.P(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			    END;

				IF WS_FIRSTID = 'Y' THEN
				    WS_IDCOL := ' id="'||WS_OBJID||WS_COUNTER||'l" ';
				ELSE
				    WS_IDCOL := '';
				END IF;

				WS_DRILL_ATALHO := REPLACE(TRIM(WS_ATALHO)||'|'||TRIM(WS_XATALHO),'||','|');
				
				IF(INSTR(WS_DRILL_ATALHO, '|', 1, 1) = 1) THEN
				    WS_DRILL_ATALHO := SUBSTR(WS_DRILL_ATALHO,2,LENGTH(WS_DRILL_ATALHO));
				END IF;

				WS_JUMP := '';

				IF(LENGTH(WS_JUMP) > 1) THEN
				  WS_JUMP := 'style="'||WS_JUMP||'"';
				END IF;

				IF(RTRIM(RET_MCOL(WS_CCOLUNA).ST_INVISIVEL) <> 'S') THEN

					IF  RTRIM(SUBSTR(RET_MCOL(WS_CCOLUNA).FORMULA,1,8))='FLEXCOL=' THEN
					    BEGIN
							WS_TEXTO_AL     := REPLACE(RET_MCOL(WS_CCOLUNA).FORMULA,'FLEXCOL=','');
							WS_NM_VAR_AL    := SUBSTR(WS_TEXTO_AL, 1 ,INSTR(WS_TEXTO_AL,'|')-1);
							WS_CD_COLUNA := FUN.GPARAMETRO(TRIM(WS_NM_VAR_AL), PRM_SCREEN => PRM_SCREEN);
							SELECT NVL(ST_ALINHAMENTO, 'LEFT') INTO WS_ALINHAMENTO
							FROM MICRO_COLUNA
							WHERE CD_MICRO_VISAO = PRM_MICRO_VISAO AND
							CD_COLUNA = WS_CD_COLUNA;
						EXCEPTION WHEN OTHERS THEN
						    WS_ALINHAMENTO := RET_MCOL(WS_CCOLUNA).ST_ALINHAMENTO;
						END;
		            ELSE
				        WS_ALINHAMENTO := RET_MCOL(WS_CCOLUNA).ST_ALINHAMENTO;
				    END IF;

					IF RET_COLGRP = 0 AND NVL(RET_MCOL(WS_CCOLUNA).COLOR, 'transparent') <> 'transparent' THEN
					    WS_JUMP := WS_JUMP||'style="background-color: '||RET_MCOL(WS_CCOLUNA).COLOR||';"';
					END IF;

					IF WS_ALINHAMENTO = 'RIGHT' THEN
						WS_JUMP := WS_JUMP||' class="dir"';
					ELSIF WS_ALINHAMENTO = 'CENTER' THEN
						WS_JUMP := WS_JUMP||' class="cen"';
					END IF;
				ELSE
					WS_JUMP := WS_JUMP||' class="no_font"';
				END IF;
				

				IF WS_CONTENT = '"' THEN
				    WS_JUMP := WS_JUMP||' class="cen"';
				END IF;

				WS_JUMP := TRIM(WS_JUMP);

				IF RET_MCOL(WS_CCOLUNA).ST_COM_CODIGO = 'N' AND RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' AND RET_MCOL(WS_CCOLUNA).CD_LIGACAO <> 'SEM' THEN

					IF LENGTH(WS_REPEAT) = 4 THEN
			            WS_REPEAT := 'hidden';
			        ELSE
			            WS_REPEAT := 'show';
			        END IF;
				END IF;

				WS_PIVOT := 'data-p="'||TRIM(WS_ATALHO)||'"';

				IF WS_LINHA_AC = 'S' AND RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR <> 'SEM' AND WS_COUNTER < WS_NCOLUMNS.COUNT AND RET_COLGRP = 0  THEN
		            IF WS_COUNTER > WS_LIMITE_I AND WS_COUNTER < (WS_NCOLUMNS.COUNT)-WS_LIMITE_F AND WS_SCOL = 1 THEN
						BEGIN
							WS_TEMP_VALOR := TO_NUMBER(NVL(RET_COLUNA, '0'));
						EXCEPTION WHEN OTHERS THEN
						    WS_TEMP_VALOR := 0;
						END;

						WS_AC_LINHA := WS_AC_LINHA + WS_TEMP_VALOR;
						WS_CONTENT  := WS_AC_LINHA;
					END IF;
				END IF;

				WS_PIVOT_COLUNA := '';


				FOR I IN (SELECT CD_CONTEUDO FROM TABLE(FUN.VPIPE_PAR(TRIM(WS_ATALHO)))) LOOP
				    WS_PIVOT_COLUNA := WS_PIVOT_COLUNA||'-'||REPLACE(I.CD_CONTEUDO, '|', '-');
				END LOOP;

				SELECT RET_MCOL(WS_CCOLUNA).CD_COLUNA||'-'||WS_PIVOT_COLUNA INTO WS_PIVOT_COLUNA FROM DUAL;

				IF LENGTH(WS_PIVOT_COLUNA) = LENGTH(RET_MCOL(WS_CCOLUNA).CD_COLUNA||'-') THEN
				    WS_PIVOT_COLUNA := RET_MCOL(WS_CCOLUNA).CD_COLUNA;
				END IF;

				WS_PIVOT_COLUNA := REPLACE(WS_PIVOT_COLUNA, '--', '-');
				
				WS_HINT := '';
				
				IF NVL(RET_MCOL(WS_CCOLUNA).LIMITE, 0) > 0 AND LENGTH(WS_CONTENT) > NVL(RET_MCOL(WS_CCOLUNA).LIMITE, 0) THEN
				    WS_HINT := WS_CONTENT;
				    WS_CONTENT := SUBSTR(WS_CONTENT, 0, RET_MCOL(WS_CCOLUNA).LIMITE);
				END IF;
				
				IF NVL(WS_HINT, 'N/A') <> 'N/A' THEN
				    WS_HINT := 'title="'||WS_HINT||'"';
				END IF;
				

				
				SELECT COUNT(*) INTO WS_COUNTV FROM TABLE(FUN.VPIPE((SELECT PROPRIEDADE FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJID AND CD_PROP = 'VISIVEL'))) WHERE COLUMN_VALUE = RET_MCOL(WS_CCOLUNA).CD_COLUNA;

        		IF WS_COUNTV = 0 OR NVL(RET_MCOL(WS_CCOLUNA).URL, 'N/A') <> 'N/A' THEN

					IF RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' AND WS_CONTENT = WS_COLUNA_ANT(WS_COUNTER) THEN
						IF LENGTH(WS_REPEAT) = 4 THEN
							IF WS_SAIDA <> 'O' THEN
								IF WS_COUNTV = 0 THEN
									HTP.TABLEDATA( FCL.FPDATA((WS_CTNULL - WS_CTCOL),0,'','')||FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA), PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN), CALIGN => '', CATTRIBUTES => ''||WS_HINT||'  data-i="'||WS_COUNTER||'" '||WS_IDCOL||FUN.CHECK_BLINK(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT, '', PRM_SCREEN)||' '||WS_JUMP||'');
								END IF;
								IF NVL(RET_MCOL(WS_CCOLUNA).URL, 'N/A') <> 'N/A' THEN
									HTP.P('<td onmouseleave="out_evento();" class="imgurl" data-url="'||REPLACE(REPLACE(RET_MCOL(WS_CCOLUNA).URL,'"',''), '$[DOWNLOAD]', 'dwu.fcl.download?arquivo=')||'" data-i="'||WS_COUNTER||'" '||WS_IDCOL||FUN.CHECK_BLINK(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT, '', PRM_SCREEN)||' '||WS_JUMP||' '||WS_PIVOT||'>');
									HTP.P('<svg style="border-radius: 2px; padding: 0px 1px; background: #DEDEDE; width: 14px;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 viewBox="0 0 58 58" style="enable-background:new 0 0 58 58;" xml:space="preserve"> <g> 	<path d="M57,6H1C0.448,6,0,6.447,0,7v44c0,0.553,0.448,1,1,1h56c0.552,0,1-0.447,1-1V7C58,6.447,57.552,6,57,6z M56,50H2V8h54V50z" 		/> 	<path d="M16,28.138c3.071,0,5.569-2.498,5.569-5.568C21.569,19.498,19.071,17,16,17s-5.569,2.498-5.569,5.569 		C10.431,25.64,12.929,28.138,16,28.138z M16,19c1.968,0,3.569,1.602,3.569,3.569S17.968,26.138,16,26.138s-3.569-1.601-3.569-3.568 		S14.032,19,16,19z"/> 	<path d="M7,46c0.234,0,0.47-0.082,0.66-0.249l16.313-14.362l10.302,10.301c0.391,0.391,1.023,0.391,1.414,0s0.391-1.023,0-1.414 		l-4.807-4.807l9.181-10.054l11.261,10.323c0.407,0.373,1.04,0.345,1.413-0.062c0.373-0.407,0.346-1.04-0.062-1.413l-12-11 		c-0.196-0.179-0.457-0.268-0.72-0.262c-0.265,0.012-0.515,0.129-0.694,0.325l-9.794,10.727l-4.743-4.743 		c-0.374-0.373-0.972-0.392-1.368-0.044L6.339,44.249c-0.415,0.365-0.455,0.997-0.09,1.412C6.447,45.886,6.723,46,7,46z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
								END IF;
							END IF;
							IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
								FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA ,'<Cell> <Data ss:Type="String">'||FUN.PTG_TRANS(FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA),PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN))||'</Data></Cell>', '', '');
							END IF;
						END IF;
					ELSE
						IF RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' THEN
							IF LENGTH(WS_REPEAT) = 4 THEN
								IF RET_COLTOT = 1 AND LENGTH(FUN.GETPROP(PRM_OBJID,'TOTAL_GERAL_TEXTO')) > 0  THEN
									IF WS_SAIDA <> 'O' THEN
										HTP.P('<td class="inv"></td>');
									END IF;
								ELSE
									IF WS_SAIDA <> 'O' THEN
										IF RET_COLTOT <> 1 THEN
											IF WS_COUNTV = 0 THEN
												HTP.TABLEDATA(FCL.FPDATA((WS_CTNULL - WS_CTCOL),0,'','')||FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA),PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN), CALIGN => '', CATTRIBUTES => ''||WS_HINT||' data-i="'||WS_COUNTER||'" '||WS_IDCOL||FUN.CHECK_BLINK(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT, '', PRM_SCREEN)||' '||WS_JUMP||'');
											END IF;
											IF NVL(RET_MCOL(WS_CCOLUNA).URL, 'N/A') <> 'N/A' THEN
												HTP.P('<td onmouseleave="out_evento();" class="imgurl" data-url="'||REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RET_MCOL(WS_CCOLUNA).URL,'"',''), '$[DOWNLOAD]', 'dwu.fcl.download?arquivo='), '$[SELF]', WS_COD_COLUNA), CHR(39), ''), '|', '')||'" data-i="'||WS_COUNTER||'" '||WS_IDCOL||FUN.CHECK_BLINK(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT, '', PRM_SCREEN)||' '||WS_JUMP||' '||WS_PIVOT||'>');
												HTP.P('<svg style="border-radius: 2px; padding: 0px 1px; background: #DEDEDE; width: 14px;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 viewBox="0 0 58 58" style="enable-background:new 0 0 58 58;" xml:space="preserve"> <g> 	<path d="M57,6H1C0.448,6,0,6.447,0,7v44c0,0.553,0.448,1,1,1h56c0.552,0,1-0.447,1-1V7C58,6.447,57.552,6,57,6z M56,50H2V8h54V50z" 		/> 	<path d="M16,28.138c3.071,0,5.569-2.498,5.569-5.568C21.569,19.498,19.071,17,16,17s-5.569,2.498-5.569,5.569 		C10.431,25.64,12.929,28.138,16,28.138z M16,19c1.968,0,3.569,1.602,3.569,3.569S17.968,26.138,16,26.138s-3.569-1.601-3.569-3.568 		S14.032,19,16,19z"/> 	<path d="M7,46c0.234,0,0.47-0.082,0.66-0.249l16.313-14.362l10.302,10.301c0.391,0.391,1.023,0.391,1.414,0s0.391-1.023,0-1.414 		l-4.807-4.807l9.181-10.054l11.261,10.323c0.407,0.373,1.04,0.345,1.413-0.062c0.373-0.407,0.346-1.04-0.062-1.413l-12-11 		c-0.196-0.179-0.457-0.268-0.72-0.262c-0.265,0.012-0.515,0.129-0.694,0.325l-9.794,10.727l-4.743-4.743 		c-0.374-0.373-0.972-0.392-1.368-0.044L6.339,44.249c-0.415,0.365-0.455,0.997-0.09,1.412C6.447,45.886,6.723,46,7,46z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
											END IF;
										END IF;
									END IF;
									IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
										FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA ,'<Cell> <Data ss:Type="String">'||FUN.PTG_TRANS(FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA),PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN))||'</Data></Cell>', '', '');
									END IF;
								END IF;
							END IF;
						ELSE
							IF(RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR IN ('PSM','PCT') AND RET_COLGRP <> 0) OR (RET_MCOL(WS_CCOLUNA).ST_GERA_REL = 'N' AND RET_COLGRP <> 0) THEN
								WS_CONTENT := ' ';
							END IF;
							IF RET_COLGRP <> 0 THEN
								IF WS_TOTAL_AC = 'S' AND WS_SCOL = 1 THEN
									IF WS_COUNTER+WS_CTNULL > WS_LIMITE_I+WS_CTCOL AND WS_COUNTER < (WS_NCOLUMNS.COUNT)-WS_LIMITE_F THEN
										BEGIN
											IF TRIM(NVL(WS_CONTENT, 'N/A')) = 'N/A' THEN
												WS_CONTENT := '';
											ELSE
												WS_CONTENT := TO_NUMBER(WS_CONTENT);
											END IF;
											WS_TEMP_VALOR2 := TO_NUMBER(WS_CONTENT);
										EXCEPTION WHEN OTHERS THEN
											WS_TEMP_VALOR2 := 0;
										END;
										WS_TOTAL_LINHA := WS_TOTAL_LINHA + WS_TEMP_VALOR2;
										WS_CONTENT     := WS_TOTAL_LINHA;
									END IF;
								END IF;
								
								IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
									FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA ,'<Cell> <Data ss:Type="String">'||FUN.PTG_TRANS(FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA), PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN))||'</Data></Cell>', '', '');
								END IF;

								IF LENGTH(FUN.GETPROP(PRM_OBJID,'CALCULADA')) > 0 THEN
									FOR I IN(SELECT COLUMN_VALUE AS VALOR FROM TABLE(FUN.VPIPE((FUN.GETPROP(PRM_OBJID,'CALCULADA'))))) LOOP
										IF INSTR(I.VALOR, '<') > 0 THEN
											IF SUBSTR(I.VALOR, 0, INSTR(I.VALOR, '<')-1) = RET_MCOL(WS_CCOLUNA).CD_COLUNA THEN
												HTP.P('<td></td>');
											END IF;
										END IF;
									END LOOP;
								END IF;

								IF WS_SAIDA <> 'O' THEN
									HTP.TABLEDATA(FUN.UM(RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_MICRO_VISAO, FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA), PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN)), CALIGN => '', CATTRIBUTES => ''||WS_HINT||' data-i="'||WS_COUNTER||'" '||WS_IDCOL||FUN.CHECK_BLINK_TOTAL(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT, '', PRM_SCREEN)||
									' '||WS_JUMP||' '||WS_PIVOT||' ' );
								END IF;
								
								IF(FUN.RET_SINAL(PRM_OBJID,RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT) <> 'nodata') THEN
									HTP.TABLEDATA(FUN.RET_SINAL(PRM_OBJID,RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT), CATTRIBUTES => 'style="width: 12px; padding: 0; text-align: center;"');
									IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
										FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA ,'<Cell> <Data ss:Type="String"></Data></Cell>', '', '');
									END IF;
								END IF;

								IF LENGTH(FUN.GETPROP(PRM_OBJID,'CALCULADA')) > 0 THEN
									FOR I IN(SELECT COLUMN_VALUE AS VALOR FROM TABLE(FUN.VPIPE((FUN.GETPROP(PRM_OBJID,'CALCULADA'))))) LOOP
										IF INSTR(I.VALOR, '>') > 0 THEN
											IF SUBSTR(I.VALOR, 0, INSTR(I.VALOR, '>')-1) = RET_MCOL(WS_CCOLUNA).CD_COLUNA THEN
												HTP.P('<td></td>');
											END IF;
										END IF;
									END LOOP;
								END IF;

							ELSE
								IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
									FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA ,'<Cell> <Data ss:Type="String">'||FUN.PTG_TRANS(FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA), PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN))||'</Data></Cell>', '', '');
								END IF;
								
								BEGIN
									IF LENGTH(FUN.GETPROP(PRM_OBJID,'CALCULADA')) > 0 THEN
										FOR I IN(SELECT COLUMN_VALUE AS VALOR, ROWNUM AS LINHA FROM TABLE(FUN.VPIPE((FUN.GETPROP(PRM_OBJID,'CALCULADA'))))) LOOP
											IF INSTR(I.VALOR, '<') > 0 THEN
												IF SUBSTR(I.VALOR, 0, INSTR(I.VALOR, '<')-1) = RET_MCOL(WS_CCOLUNA).CD_COLUNA THEN
													WS_CALCULADA := FUN.XEXEC('EXEC='||SUBSTR(I.VALOR, INSTR(I.VALOR, '<')+1), PRM_SCREEN, WS_CONTENT, WS_CONTEUDO_ANT);
													
													SELECT NVL(MASCARA, TRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA)) INTO WS_CALCULADA_M FROM(SELECT COLUMN_VALUE AS MASCARA, ROWNUM AS LINHA FROM TABLE(FUN.VPIPE((FUN.GETPROP(PRM_OBJID,'CALCULADA_M'))))) WHERE LINHA = I.LINHA;
													HTP.P('<td '||WS_JUMP||'>'||FUN.IFMASCARA(WS_CALCULADA, WS_CALCULADA_M, PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN)||'</td>');
												END IF;
											END IF;
										END LOOP;
									END IF;
								EXCEPTION WHEN OTHERS THEN
									HTP.P('<td '||WS_JUMP||' data-err="'||SQLERRM||'">err</td>');
								END;

								IF WS_SAIDA <> 'O' THEN
									HTP.TABLEDATA(FUN.UM(RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_MICRO_VISAO, FUN.IFMASCARA(WS_CONTENT, RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA), PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN)), CALIGN => '', CATTRIBUTES => ''||WS_HINT||' data-i="'||WS_COUNTER||'" '||WS_IDCOL||
									' '||WS_JUMP||' '||WS_PIVOT||' ' );

									BEGIN
										IF LENGTH(FUN.GETPROP(PRM_OBJID,'CALCULADA')) > 0 THEN
											FOR I IN(SELECT COLUMN_VALUE AS VALOR, ROWNUM AS LINHA FROM TABLE(FUN.VPIPE((FUN.GETPROP(PRM_OBJID,'CALCULADA'))))) LOOP
												IF INSTR(I.VALOR, '>') > 0 THEN
													IF SUBSTR(I.VALOR, 0, INSTR(I.VALOR, '>')-1) = RET_MCOL(WS_CCOLUNA).CD_COLUNA THEN
														WS_CALCULADA := FUN.XEXEC('EXEC='||SUBSTR(I.VALOR, INSTR(I.VALOR, '>')+1), PRM_SCREEN, WS_CONTENT, WS_CONTEUDO_ANT);

														SELECT NVL(MASCARA, TRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA)) INTO WS_CALCULADA_M FROM(SELECT COLUMN_VALUE AS MASCARA, ROWNUM AS LINHA FROM TABLE(FUN.VPIPE((FUN.GETPROP(PRM_OBJID,'CALCULADA_M'))))) WHERE LINHA = I.LINHA;
														HTP.P('<td '||WS_JUMP||'>'||FUN.IFMASCARA(WS_CALCULADA, WS_CALCULADA_M, PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN)||'</td>');
													END IF;
												END IF;
											END LOOP;
										END IF;
									EXCEPTION WHEN OTHERS THEN
										HTP.P('<td '||WS_JUMP||' data-err="'||SQLERRM||'">err</td>');
									END;

								END IF;
								
								IF(FUN.RET_SINAL(PRM_OBJID,RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT) <> 'nodata') THEN
									IF WS_SAIDA <> 'O' THEN
										HTP.TABLEDATA(FUN.RET_SINAL(PRM_OBJID,RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT), CATTRIBUTES => ''||WS_HINT||' '||'style="width: 12px; padding: 0; text-align: center;"');
									END IF;
									IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
										FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA ,'<Cell><Data ss:Type="String"></Data></Cell>', '', '');
									END IF;
								END IF;
								
							END IF;
						END IF;
					END IF;
				END IF;

				IF LENGTH(FUN.CHECK_BLINK_LINHA(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_LINHA, RET_COLUNA, PRM_SCREEN)) > 7 AND RET_COLGRP = 0 THEN
				    WS_BLINK_LINHA := FUN.CHECK_BLINK_LINHA(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_LINHA, RET_COLUNA, PRM_SCREEN);
				END IF;

				IF LENGTH(WS_REPEAT) = 4 THEN
				    WS_COUNT := WS_COUNT+1;
					WS_ARRAY_ATUAL(WS_COUNT) := RET_COLUNA;
					WS_CLASS_ATUAL(WS_COUNT) := WS_JUMP;
				END IF;

				WS_JUMP := '';
				WS_CHECK := '';

				WS_COLUNA_ANT(WS_COUNTER) := RET_COLUNA;
				WS_ARR_ANTERIOR(WS_COUNTER) := RET_COLUNA;

		        WS_CONTEUDO_ANT := WS_CONTENT;

	    	END LOOP;

			IF WS_SAIDA <> 'O' THEN
			    IF WS_BLINK_LINHA <> 'N/A' THEN HTP.P(WS_BLINK_LINHA); END IF;
			END IF;

		    WS_BLINK_LINHA := 'N/A';

		    WS_FIRSTID := 'N';
		    IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
	            FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '</Row>', '', '');
	        END IF;
		    HTP.P('</tr>');

		
		WS_AC_LINHA := 0;
		WS_TOTAL_LINHA := 0;
		WS_COUNT := 0;
		
	END LOOP;

	WS_TOTAL_LINHA := 0;
	WS_AC_LINHA := 0;
	DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);

	IF WS_SAIDA <> 'O' THEN
		IF FUN.GETPROP(PRM_OBJID,'TOTAL_SEPARADO') = 'S' THEN
			WS_BLINK_LINHA := 'N/A';
			HTP.P('<tr class="total duplicado" data-i="0">');
				HTP.P('<td colspan="'||DIMENSAO_SOMA||'" style="text-align: right;">'||FUN.GETPROP(PRM_OBJID,'TOTAL_SEPARADO_TEXTO')||'</td>');
				FOR I IN DIMENSAO_SOMA..WS_ARRAY_ATUAL.COUNT LOOP
					 BEGIN
						 WS_ARRAY_ATUAL(I) := TO_NUMBER(NVL(TRIM(WS_ARRAY_ATUAL(I-1)), 0))+TO_NUMBER(NVL(TRIM(WS_ARRAY_ATUAL(I)), 0));
						 HTP.P('<td '||WS_CLASS_ATUAL(I)||' '||FUN.CHECK_BLINK_TOTAL(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_ARRAY_ATUAL(I), '', PRM_SCREEN)||'>'||FUN.IFMASCARA(WS_ARR_ATUAL(I),RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA), PRM_MICRO_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJID, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN)||'</td>');

						 IF LENGTH(FUN.CHECK_BLINK_LINHA(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_LINHA+1, RET_COLUNA, PRM_SCREEN)) > 7 THEN
							 WS_BLINK_LINHA := FUN.CHECK_BLINK_LINHA(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_LINHA+1, RET_COLUNA, PRM_SCREEN);
						 END IF;
						 IF WS_BLINK_LINHA <> 'N/A' THEN HTP.P(WS_BLINK_LINHA); END IF;
						 WS_BLINK_LINHA := 'N/A';
					 EXCEPTION WHEN OTHERS THEN
						 HTP.P('<td></td>');
					 END;
				END LOOP;
			HTP.P('</tr>');
		END IF;
	END IF;

END CONSULTA_DADOS;

END UPQUERY;