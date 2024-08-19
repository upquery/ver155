SET DEFINE OFF;
CREATE OR REPLACE PACKAGE BODY OBJ  IS

PROCEDURE MENU ( PRM_OBJETO  VARCHAR2 DEFAULT NULL,
                 PRM_SCREEN  VARCHAR2 DEFAULT NULL,
                 PRM_POSICAO VARCHAR2 DEFAULT NULL,
                 PRM_POSY    VARCHAR2 DEFAULT NULL,
                 PRM_POSX    VARCHAR2 DEFAULT NULL ) AS

		CURSOR CRS_ITENS ( PRM_USUARIO VARCHAR2,
		                   PRM_ADMIN   VARCHAR2 ) IS
		
		SELECT	CLL.CD_OBJETO, NM_OBJETO, TP_OBJETO, NM_ITEM,OBJ.ATRIBUTOS
		FROM	CALL_LIST CLL
        LEFT JOIN OBJETOS OBJ ON OBJ.CD_OBJETO = CLL.CD_OBJETO
        LEFT JOIN CALL_NAME ON CALL_NAME.CD_OBJETO = CLL.CD_OBJETO
		WHERE	CLL.CD_LIST = PRM_OBJETO AND (
		    CLL.CD_OBJETO NOT IN ( SELECT CD_OBJETO FROM OBJECT_RESTRICTION WHERE (USUARIO = PRM_USUARIO AND ST_RESTRICAO = 'I') OR (PRM_ADMIN = 'A' AND ST_RESTRICAO = 'X') ) 
		    OR
			( 
			CLL.CD_OBJETO NOT IN ( SELECT CD_OBJETO FROM OBJECT_RESTRICTION WHERE USUARIO = PRM_USUARIO AND ST_RESTRICAO = 'I' ) AND
			CLL.CD_OBJETO IN ( SELECT CD_OBJETO FROM OBJECT_RESTRICTION WHERE (PRM_ADMIN = 'A' AND ST_RESTRICAO = 'X') OR (USUARIO = PRM_USUARIO AND ST_RESTRICAO = 'L') ) 
			)

		)
		ORDER BY ORDEM, NM_OBJETO;

	    WS_ITENS	CRS_ITENS%ROWTYPE;

		WS_TITULO	VARCHAR2(400);
		WS_TIPO     VARCHAR2(40);
		WS_USUARIO  VARCHAR2(80);
	    WS_ADMIN    VARCHAR2(80);
		WS_PADRAO   VARCHAR2(80) := 'PORTUGUESE';
		WS_ATT      VARCHAR2(500);
		WS_URL      VARCHAR2(500);
		WS_ALT      VARCHAR2(80);

BEGIN

    WS_USUARIO := GBL.GETUSUARIO;
	WS_ADMIN   := GBL.GETNIVEL;

	BEGIN
        SELECT CONTEUDO INTO WS_PADRAO
        FROM   PARAMETRO_USUARIO
        WHERE  CD_USUARIO = WS_USUARIO AND
               CD_PADRAO='CD_LINGUAGEM';
    EXCEPTION
        WHEN OTHERS THEN
            WS_PADRAO := 'PORTUGUESE';
    END;

    HTP.P('<div class="dragme pro6" id="'||PRM_OBJETO||'" title="'||PRM_OBJETO||'" data-top="'||PRM_POSY||'" data-left="'||PRM_POSX||'" class="dragme pro6">');
		
	SELECT NM_OBJETO INTO WS_TITULO
	FROM OBJETOS
	WHERE CD_OBJETO = PRM_OBJETO AND TP_OBJETO = 'CALL_LIST';

	IF WS_ADMIN = 'A' THEN
		HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||PRM_OBJETO||'more">');
	   		HTP.P('<span class="preferencias" title="'||FUN.LANG('Propriedades')||'"></span>');
			HTP.P('<span class="lightbulb" title="'||FUN.LANG('Lista do Menu')||'"></span>');
			HTP.P('<span>');
				FCL.BUTTON_LIXO('dl_obj', PRM_OBJETO => PRM_OBJETO);
			HTP.P('</span>');
		HTP.P('</span>');
		
	    HTP.P('<h2>'||FUN.UTRANSLATE('NM_OBJETO', PRM_OBJETO, WS_TITULO, WS_PADRAO)||'</h2>');
	ELSE
	    HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||PRM_OBJETO||'more" style="max-width: 26px;">');
			HTP.P('<span class="lightbulb" title="'||FUN.LANG('Lista do Menu')||'"></span>');
		HTP.P('</span>');
		HTP.P('<h2>'||FUN.UTRANSLATE('NM_OBJETO', PRM_OBJETO, WS_TITULO, WS_PADRAO)||'</h2>');
	END IF;
		
		HTP.P('<ul id="space-options">');
		
		    WS_URL:='dwu.fcl.download_tab?prm_arquivo=';
			WS_ALT := '&prm_alternativo=';


			OPEN CRS_ITENS(WS_USUARIO, WS_ADMIN);
				LOOP
				FETCH CRS_ITENS INTO WS_ITENS;
				EXIT WHEN CRS_ITENS%NOTFOUND;

				 	
				IF WS_ITENS.ATRIBUTOS <> 'N/A' AND WS_ITENS.TP_OBJETO <> 'RELATORIO' THEN
				    WS_ATT :=  'download="'||WS_ITENS.ATRIBUTOS||'" href="'||WS_URL||WS_ITENS.ATRIBUTOS||WS_ALT||'"';
				END IF;

					WS_TIPO := WS_ITENS.TP_OBJETO;
					
					IF WS_TIPO = 'SCRIPT' THEN

						HTP.P('<li class="SCRIPT" id="'||WS_ITENS.CD_OBJETO||'menu"><a onclick="appendar(''dwu.obj.show_objeto?prm_objeto='||WS_ITENS.CD_OBJETO||'&PRM_ZINDEX=2&prm_posx=100px&prm_posy=100px&prm_screen=''+tela, '''', false); setTimeout(function(){ remover(''script-load''); }, 10000);">'||NVL(WS_ITENS.NM_ITEM, WS_ITENS.NM_OBJETO)||'</a></li>');
					
					ELSIF WS_TIPO ='FILE' THEN
					    HTP.P('<li class="'||WS_TIPO||'" id="'||WS_ITENS.CD_OBJETO||'menu"><a href="dwu.fcl.download_tab?prm_arquivo='||WS_ITENS.ATRIBUTOS||'">'||WS_ITENS.NM_OBJETO||'</a>');
					ELSE
						IF TRIM(WS_ITENS.NM_ITEM) <> '''' THEN

							HTP.P('<li class="'||WS_TIPO||'" id="'||WS_ITENS.CD_OBJETO||'menu"><a>'||FUN.SUBPAR(WS_ITENS.NM_ITEM, PRM_SCREEN)||'</a></li>');
						ELSE

							HTP.P('<li class="'||WS_TIPO||'" id="'||WS_ITENS.CD_OBJETO||'menu"><a>'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', WS_ITENS.CD_OBJETO, WS_ITENS.NM_OBJETO, WS_PADRAO), PRM_SCREEN)||'</a></li>');
						END IF;
					END IF;
				END LOOP;
			CLOSE CRS_ITENS;

		HTP.P('</ul>');

	HTP.P('</div>');

END MENU;

PROCEDURE FLOAT_PAR ( PRM_OBJETO VARCHAR2 DEFAULT NULL ) AS
BEGIN

    HTP.P('<div onmousedown="event.stopPropagation();" class="dragme" id="'||PRM_OBJETO||'"></div>');

END FLOAT_PAR;

PROCEDURE FLOAT_FILTER ( PRM_OBJETO VARCHAR2 DEFAULT NULL ) AS
BEGIN

    HTP.P('<div onmousedown="event.stopPropagation();" class="dragme" id="'||PRM_OBJETO||'"></div>');

END FLOAT_FILTER;

PROCEDURE ICONE ( PRM_OBJETO      VARCHAR2 DEFAULT NULL,
                  PRM_PROPAGATION VARCHAR2 DEFAULT NULL,
				  PRM_SCREEN      VARCHAR2 DEFAULT NULL,
				  PRM_DRILL       VARCHAR2 DEFAULT NULL,
				  PRM_NOME        VARCHAR2 DEFAULT NULL,
				  PRM_POSICAO     VARCHAR2 DEFAULT NULL,
				  PRM_POSY        VARCHAR2 DEFAULT NULL,
				  PRM_POSX        VARCHAR2 DEFAULT NULL ) AS

	WS_ALINHAMENTO_TIT VARCHAR2(40);
	WS_STYLE           VARCHAR2(40);
	WS_ATRIBUTOS       VARCHAR2(400);
	WS_DS_OBJETO       VARCHAR2(80);
	WS_PROPS_BORDA     VARCHAR2(80);

BEGIN

    SELECT ATRIBUTOS, DS_OBJETO INTO
		WS_ATRIBUTOS, WS_DS_OBJETO
	FROM   OBJETOS
	WHERE  CD_OBJETO=PRM_OBJETO;

	WS_PROPS_BORDA := 'border: 1px solid '||FUN.GETPROP(PRM_OBJETO, 'BORDA_COR');

    HTP.P('<div onmousedown="'||PRM_PROPAGATION||'" id="'||RTRIM(PRM_OBJETO)||'" data-top="'||PRM_POSY||'" data-left="'||PRM_POSX||'" data-script="'||FUN.GETPROP(PRM_OBJETO,'COMANDO')||'" data-chamada="'||FUN.GETPROP(PRM_OBJETO,'CHAMADA')||'" data-parametros="'||FUN.GETPROP(PRM_OBJETO,'PARAMETROS')||'" style="'||PRM_POSICAO||'; '||WS_PROPS_BORDA||'; min-width: 52px; text-align: center;" class="dragme icone">');

		OBJ.OPCOES(PRM_OBJETO, 'ICONE', '', '', PRM_SCREEN, PRM_DRILL);

		IF INSTR(FUN.GETPROP(PRM_OBJETO, 'LARGURA'), '%') > 0 THEN
			WS_STYLE := FUN.GETPROP(PRM_OBJETO, 'LARGURA');
		ELSE
			WS_STYLE := REPLACE(FUN.GETPROP(PRM_OBJETO, 'LARGURA'), 'px', '')||'px';
		END IF;

		WS_ALINHAMENTO_TIT := FUN.GETPROP(PRM_OBJETO,'ALIGN_TIT');
		
		IF WS_ALINHAMENTO_TIT = 'left' THEN
			WS_ALINHAMENTO_TIT := WS_ALINHAMENTO_TIT||'; text-indent: 14px';
		END IF;

		IF GBL.GETNIVEL= 'A' THEN
			HTP.P('<a class="wd_move" style="text-align: '||WS_ALINHAMENTO_TIT||'; cursor: move; display: block; text-decoration: none; color: '||FUN.GETPROP(PRM_OBJETO, 'TIT_COLOR')||'; font-style: '||FUN.GETPROP(PRM_OBJETO, 'TIT_IT')||'; font-weight: '||FUN.GETPROP(PRM_OBJETO, 'TIT_BOLD')||'; font-family: '||FUN.GETPROP(PRM_OBJETO, 'TIT_FONT')||'; font-size: '||FUN.GETPROP(PRM_OBJETO, 'TIT_SIZE')||'; background-color: '||FUN.GETPROP(PRM_OBJETO, 'TIT_BGCOLOR')||'" id="'||PRM_OBJETO||'_ds">'||PRM_NOME||'</a>');
			HTP.IMG(WS_ATRIBUTOS, CATTRIBUTES => ' style="text-align: '||WS_ALINHAMENTO_TIT||'; display: block; margin: 0 auto; cursor: pointer; max-width: '||WS_STYLE||'; max-height: '||FUN.GETPROP(PRM_OBJETO, 'ALTURA')||'px; height: auto; '||FUN.PUT_STYLE(PRM_OBJETO, 'BGCOLOR', 'ICONE')||'" cellspacing="0" border="0" id="'||PRM_OBJETO||'_gr" class="wd_move" onclick="sos('''||PRM_OBJETO||''');"');
		ELSE
			HTP.P('<a style="display: block; text-decoration: none; color: '||FUN.GETPROP(PRM_OBJETO, 'TIT_COLOR')||'; font-style: '||FUN.GETPROP(PRM_OBJETO, 'TIT_IT')||'; font-weight: '||FUN.GETPROP(PRM_OBJETO, 'TIT_BOLD')||'; font-family: '||FUN.GETPROP(PRM_OBJETO, 'TIT_FONT')||'; font-size: '||FUN.GETPROP(PRM_OBJETO, 'TIT_SIZE')||'; background-color: '||FUN.GETPROP(PRM_OBJETO, 'TIT_BGCOLOR')||'" id="'||PRM_OBJETO||'_ds">'||PRM_NOME||'</a>');
			HTP.IMG(WS_ATRIBUTOS, CATTRIBUTES => ' style="display: block; margin: 0 auto; cursor: pointer; max-width: '||WS_STYLE||'; max-height: '||FUN.GETPROP(PRM_OBJETO, 'ALTURA')||'px; height: auto; '||FUN.PUT_STYLE(PRM_OBJETO, 'BGCOLOR', 'ICONE')||'" cellspacing="0" border="0" id="'||PRM_OBJETO||'_gr" onclick="sos('''||PRM_OBJETO||''');"');
		END IF;

	HTP.P('</div>');

END ICONE;

PROCEDURE IMAGE ( PRM_OBJETO      VARCHAR2 DEFAULT NULL,
                  PRM_PROPAGATION VARCHAR2 DEFAULT NULL,
				  PRM_SCREEN      VARCHAR2 DEFAULT NULL,
				  PRM_DRILL       VARCHAR2 DEFAULT NULL,
				  PRM_NOME        VARCHAR2 DEFAULT NULL,
				  PRM_POSICAO     VARCHAR2 DEFAULT NULL,
				  PRM_POSY        VARCHAR2 DEFAULT NULL,
				  PRM_POSX        VARCHAR2 DEFAULT NULL ) AS 
				  
		WS_ATRIBUTOS VARCHAR2(80);
		WS_DS_OBJETO VARCHAR2(80);

		WS_BGCOLOR	  VARCHAR2(80);
		WS_LARGURA    VARCHAR2(80);	
		WS_MAXEIGHT   VARCHAR2(80);	
		WS_PROP_BORDA VARCHAR2(80);
	
	BEGIN

    SELECT ATRIBUTOS, DS_OBJETO INTO
		WS_ATRIBUTOS, WS_DS_OBJETO
	FROM   OBJETOS
	WHERE  CD_OBJETO = PRM_OBJETO;

    
	WS_BGCOLOR    := 'background-color: '||FUN.GETPROP(PRM_OBJETO, 'BGCOLOR');
	WS_MAXEIGHT   := 'max-height:       '||FUN.GETPROP(PRM_OBJETO, 'ALTURA')||'px';
	WS_PROP_BORDA := 'border: 1px solid '||FUN.GETPROP(PRM_OBJETO, 'BORDA_COR');
	
	IF INSTR(FUN.GETPROP(PRM_OBJETO, 'LARGURA'), '%') > 0 THEN
		WS_LARGURA := 'width: '||FUN.GETPROP(PRM_OBJETO, 'LARGURA');
	ELSE
		WS_LARGURA := 'width: '||REPLACE(FUN.GETPROP(PRM_OBJETO, 'LARGURA'), 'px', '')||'px';
	END IF;
		
	HTP.P('<div onmousedown="'||PRM_PROPAGATION||'" class="dragme icone" id="'||TRIM(PRM_OBJETO)||'" title="'||TRIM(PRM_OBJETO)||'" data-top="'||PRM_POSY||'" data-left="'||PRM_POSX||'" style=" '||PRM_POSICAO||'; '||WS_PROP_BORDA||';" >');

		
		HTP.PRN('<style> 
		div#'||TRIM(PRM_OBJETO)||' { min-width: 52px; }
		img#'||TRIM(PRM_OBJETO)||'_gr { '||WS_BGCOLOR||'; '||WS_LARGURA||'; '||WS_MAXEIGHT||'; height: auto; }
		span#'||TRIM(PRM_OBJETO)||'_ds { position: relative; z-index: 1; margin-top: -8px; letter-spacing: -2px; font-size: 12px; } </style>');
		
		OBJ.OPCOES(PRM_OBJETO, 'IMAGE', '', '', PRM_SCREEN, PRM_DRILL);

		IF GBL.GETNIVEL = 'A' THEN
			HTP.P('<span id="'||PRM_OBJETO||'_ds" class="wd_move">===</span>');
		END IF;

		HTP.IMG(LOWER(FUN.SUBPAR(WS_ATRIBUTOS, PRM_SCREEN)), CATTRIBUTES => ' data-screen="'||PRM_SCREEN||'" id="'||PRM_OBJETO||'_gr" cellspacing="0" border="0" /');
	
	HTP.P('</div>');

END IMAGE;

PROCEDURE VALOR ( PRM_OBJETO      VARCHAR2 DEFAULT NULL,
                  PRM_DRILL       VARCHAR2 DEFAULT NULL,
				  PRM_DESC        VARCHAR2 DEFAULT NULL,
				  PRM_VISAO       VARCHAR2 DEFAULT NULL,
				  PRM_PARAMETROS  VARCHAR2 DEFAULT NULL,
				  PRM_PROPAGATION VARCHAR2 DEFAULT NULL,
				  PRM_SCREEN      VARCHAR2 DEFAULT NULL,
				  PRM_POSX        VARCHAR2 DEFAULT NULL,
				  PRM_POSY        VARCHAR2 DEFAULT NULL,
                  PRM_POSICAO     VARCHAR2 DEFAULT NULL,
				  PRM_USUARIO     VARCHAR2 DEFAULT NULL ) AS

    WS_OBJ             VARCHAR2(200);
	WS_MASCARA         VARCHAR2(100);
	WS_UNIDADE         VARCHAR2(100);
	WS_FORMULA         VARCHAR2(1000);
	WS_GRADIENTE       VARCHAR2(200);
	WS_COMPLEMENTO     VARCHAR2(800);
	WS_GRADIENTE_T     VARCHAR2(200);
	WS_SUBTITULO       VARCHAR2(2000)  := ' ';
	WS_TIP             VARCHAR2(100);
	WS_ALINHAMENTO_TIT VARCHAR2(100);
	WS_GOTO            VARCHAR2(200);
	WS_FILTRO          VARCHAR2(800);
	WS_CLASS           VARCHAR2(100);
	WS_USUARIO         VARCHAR2(80);
	WS_ADMIN           VARCHAR2(20);
	WS_COUNT           NUMBER;
	WS_COUNT_META      NUMBER;
	WS_VALOR_PONTO     VARCHAR2(400);
	WS_VALOR_UM        VARCHAR2(80);
	WS_VALOR_META      VARCHAR2(80);

	WS_PROP_ALIGN_TIT    VARCHAR2(40);
	WS_PROP_ALTURA       VARCHAR2(40);
	WS_PROP_BG           VARCHAR2(80);
	WS_PROP_BORDA		 VARCHAR2(40);
	WS_PROP_DEGRADE      VARCHAR2(40);
	WS_PROP_DEGRADE_TIPO VARCHAR2(40);
	WS_PROP_LARGURA      VARCHAR2(40);
	WS_PROP_RADIUS       VARCHAR2(40);
	WS_PROP_TIT_BG       VARCHAR2(40);
	WS_PROP_SIZE         VARCHAR2(40);
	WS_PROP_BOLD         VARCHAR2(40);
	WS_PROP_COLOR        VARCHAR2(40);
	WS_PROP_IMGOPT       VARCHAR2(40);
	WS_PROP_FONT         VARCHAR2(40);
	WS_PROP_IT           VARCHAR2(40);
    ws_blink             varchar2(4000);
	ws_aplica_destaque   varchar2(40);
	WS_LARGURA_VALOR	 varchar2(10);
	WS_MSG_DADOS		 VARCHAR2(100);

	WS_ARR ARR;

	WS_ERROR             EXCEPTION;

BEGIN

	WS_USUARIO := PRM_USUARIO;
	IF NVL(WS_USUARIO, 'N/A') = 'N/A' THEN
        WS_USUARIO := GBL.GETUSUARIO;
	END IF;

    WS_ARR := FUN.GETPROPS(PRM_OBJETO, 'VALOR', 'ALTURA|APLICA_DESTAQUE|BGCOLOR|BOLD|BORDA_COR|COLOR|DEGRADE|DEGRADE_TIPO|FONT|IMG_OPTION|IT|LARGURA|NO_RADIUS|SIZE|TIT_BGCOLOR', 'DWU');

    WS_PROP_ALTURA       := WS_ARR(1);
	ws_aplica_destaque   := ws_arr(2);
	WS_PROP_BG           := WS_ARR(3);
	WS_PROP_BOLD         := WS_ARR(4);
	WS_PROP_BORDA        := WS_ARR(5);
	WS_PROP_COLOR        := WS_ARR(6);
	WS_PROP_DEGRADE      := WS_ARR(7);
	WS_PROP_DEGRADE_TIPO := WS_ARR(8);
	WS_PROP_FONT         := WS_ARR(9);
	WS_PROP_IMGOPT       := WS_ARR(10);
	WS_PROP_IT           := WS_ARR(11);
	WS_PROP_LARGURA      := WS_ARR(12);
	WS_PROP_RADIUS       := WS_ARR(13);
	WS_PROP_SIZE         := WS_ARR(14);
	WS_PROP_TIT_BG       := WS_ARR(15);

    WS_COMPLEMENTO := '';

	BEGIN
		SELECT NM_MASCARA, NM_UNIDADE, FORMULA INTO WS_MASCARA, WS_UNIDADE, WS_FORMULA
		FROM   MICRO_COLUNA
		WHERE  CD_MICRO_VISAO = PRM_VISAO AND
			CD_COLUNA = SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1);
	EXCEPTION WHEN OTHERS THEN
		RAISE WS_ERROR;
	END;

	SELECT COUNT(*) INTO WS_COUNT FROM COLUMN_RESTRICTION WHERE USUARIO = USER AND CD_MICRO_VISAO = PRM_VISAO AND CD_COLUNA IN (SELECT COLUMN_VALUE FROM TABLE(FUN.VPIPE(PRM_PARAMETROS)));
	
	SELECT COUNT(*) INTO WS_COUNT_META FROM MICRO_COLUNA WHERE CD_COLUNA = REPLACE(REPLACE(WS_VALOR_META, '$[', ''), ']', '') AND CD_MICRO_VISAO = PRM_VISAO;
	
	WS_VALOR_PONTO := FUN.VALOR_PONTO(PRM_PARAMETROS, PRM_VISAO, PRM_OBJETO, PRM_SCREEN );


	IF WS_COUNT = 0 THEN

		IF  PRM_DRILL = 'Y' THEN
			WS_OBJ := PRM_OBJETO||'trl';
		ELSE
			WS_OBJ := PRM_OBJETO;
		END IF;

		WS_LARGURA_VALOR := FUN.GETPROP(prm_objeto,'LARGURA_VALOR');
		
		HTP.P('<div data-borda="" onmousedown="'||PRM_PROPAGATION||'" id="'||TRIM(WS_OBJ)||'" data-swipe="" data-top="'||PRM_POSY||'" data-left="'||PRM_POSX||'" data-visao="'||PRM_VISAO||'" class="dragme dados">');

			IF TRIM(WS_PROP_DEGRADE) = 'S' OR WS_PROP_IMGOPT = 'S' THEN
				IF NVL(WS_PROP_DEGRADE_TIPO, '%??%') = '%??%' THEN
					WS_GRADIENTE_T := 'linear';
				ELSE
					WS_GRADIENTE_T := WS_PROP_DEGRADE_TIPO;
				END IF;
				WS_GRADIENTE := 'background: '||WS_GRADIENTE_T||'-gradient('||WS_PROP_TIT_BG||', '||WS_PROP_BG||');';
			ELSE
				WS_GRADIENTE := 'background-color: '||WS_PROP_BG||';';
			END IF;
			

			IF NVL(WS_LARGURA_VALOR,'AUTO') <> 'AUTO' THEN
				WS_LARGURA_VALOR:='width:'||WS_LARGURA_VALOR||';';
			ELSE
				WS_LARGURA_VALOR:='';
			END IF;
			HTP.PRN('<style> 
			div#'||TRIM(WS_OBJ)||' { 
				white-space: nowrap; 
				border: 1px solid '||WS_PROP_BORDA||'; 
				'||PRM_POSICAO||';
				'||WS_LARGURA_VALOR||'
				'||WS_GRADIENTE||'
			}
			div#dados_'||TRIM(WS_OBJ)||', ul#'||WS_OBJ||'-filterlist {
				display: none;
			}');
		
			IF WS_PROP_RADIUS <> 'N' THEN
				HTP.PRN('
				div#'||WS_OBJ||', div#'||WS_OBJ||'_ds, div#'||WS_OBJ||'_fakeds { 
					border-radius: 0 !important; 
				} 
				div#'||WS_OBJ||' span#'||WS_OBJ||'more { 
					border-radius: 0 0 0 6px; 
				} 
				a#'||PRM_OBJETO||'fechar { 
					border-radius: 0 0 0 6px; 
				} 
				div#'||PRM_OBJETO||'_vl { 
					border-radius: 0; 
				}');
			
			END IF;

			IF WS_PROP_IMGOPT = 'S' THEN
				HTP.PRN('
				div#'||WS_OBJ||' div.img_container img {
					max-width: 100%; 
					border-radius: '||FUN.GETPROP(PRM_OBJETO,'IMG_RADIUS')||'; 
					height: '||FUN.GETPROP(PRM_OBJETO,'IMG_ALTURA')||'; 
					width: '||FUN.GETPROP(PRM_OBJETO,'IMG_LARGURA')||'; 
					background-color: '||FUN.GETPROP(PRM_OBJETO,'IMG_BGCOLOR')||'; 
					border: 1px solid '||FUN.GETPROP(PRM_OBJETO,'IMG_BORDA')||'; 
					padding: '||FUN.GETPROP(PRM_OBJETO,'IMG_ESPACAMENTO')||';
				}');
			END IF;

			--FUN.CHECK_BLINK(PRM_OBJETO, SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1), NVL(WS_VALOR_PONTO, 'N/A'), WS_PROP_COLOR)||' 
			
			HTP.PRN('
			span#'||TRIM(PRM_OBJETO)||'_ds { 
				position: relative;
				z-index: 1;
				margin-top: -8px; 
				letter-spacing: -2px; 
				font-size: 12px;
			}
			div#ctnr_'||WS_OBJ||' {
				max-width: inherit; 
				min-width: inherit; 
				width:  '||WS_PROP_LARGURA||'px; 
				height: '||WS_PROP_ALTURA||'px;
			}
		
			div#'||WS_OBJ||'_vl {
				cursor: pointer;
				font-size: '||WS_PROP_SIZE||';
				color: '||WS_PROP_COLOR||'; 
				font-style: '||WS_PROP_IT||'; 
				font-weight: '||WS_PROP_BOLD||'; 
				font-family: '||WS_PROP_FONT||';
				');
				IF NVL(FUN.GETPROP(PRM_OBJETO,'META'), 'N/A') <> 'N/A' THEN
					HTP.PRN('border-radius: 0 !important;');
				ELSE
					IF WS_PROP_IMGOPT = 'S' THEN
						HTP.PRN('border-radius: 5px 0 5px 0;');
					END IF;	
				END IF;
				IF SUBSTR(TRIM(FUN.PUT_STYLE(PRM_OBJETO, 'DEGRADE', WS_TIP)), 5, 1) <> 'S' AND WS_PROP_IMGOPT <> 'S' THEN
					HTP.PRN('background-color: '||WS_PROP_BG||';');
				END IF;
			HTP.PRN('}');


			
			IF NVL(FUN.GETPROP(PRM_OBJETO,'META'), 'N/A') <> 'N/A' THEN
				HTP.PRN('div#'||WS_OBJ||'_mt {
					border-radius: 0 0 5px 5px; 
					padding: 2px; 
					text-align: center;
					color: '||WS_PROP_COLOR||'; 
					font-style: '||WS_PROP_IT||'; 
					font-weight: '||WS_PROP_BOLD||'; 
					font-family: '||WS_PROP_FONT||'; 
					font-size: 10px;');
				BEGIN
					IF WS_COUNT_META <> 0 THEN
						HTP.PRN(FUN.CHECK_BLINK(PRM_OBJETO, SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1), NVL(WS_VALOR_PONTO, 'N/A'), FUN.PUT_STYLE(PRM_OBJETO, 'COLOR', 'VALOR')));
					ELSE
						HTP.PRN(FUN.CHECK_BLINK(PRM_OBJETO, SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1), NVL(WS_VALOR_META, 'N/A'), FUN.PUT_STYLE(PRM_OBJETO, 'COLOR', 'VALOR')));
					END IF;
				EXCEPTION WHEN OTHERS THEN
					HTP.PRN(FUN.CHECK_BLINK(PRM_OBJETO, SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1), NVL(WS_VALOR_META, 'N/A'), FUN.PUT_STYLE(PRM_OBJETO, 'COLOR', 'VALOR')));
				END;
			END IF;
			HTP.PRN('</style>');


			SELECT COUNT(*) INTO WS_COUNT FROM GOTO_OBJETO WHERE CD_OBJETO = TRIM(PRM_OBJETO);

			HTP.P('<div id="dados_'||TRIM(WS_OBJ)||'" data-tipo="VALOR" data-swipe="" data-visao="'||PRM_VISAO||'" data-width="'||WS_PROP_LARGURA||'" data-height="'||WS_PROP_ALTURA||'" data-top="'||PRM_POSY||'" data-left="'||PRM_POSX||'" data-drill="'||WS_COUNT||'"></div>');

			OBJ.OPCOES(WS_OBJ, 'VALOR', PRM_PARAMETROS, PRM_VISAO, PRM_SCREEN, PRM_DRILL, PRM_USUARIO => WS_USUARIO);

			HTP.PRN('<ul id="'||WS_OBJ||'-filterlist">');
				HTP.PRN(FUN.SHOW_FILTROS(PRM_PARAMETROS, '', '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN, PRM_USUARIO => WS_USUARIO));
			HTP.PRN('</ul>');

			HTP.PRN('<ul id="'||WS_OBJ||'-destaquelist" style="display: none;" >');
				HTP.PRN(FUN.SHOW_DESTAQUES(PRM_PARAMETROS, '', '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN, PRM_USUARIO => WS_USUARIO));
			HTP.PRN('</ul>');
			
			IF FUN.GETPROP(PRM_OBJETO,'IMG_OPTION') = 'S' THEN
				HTP.P('<div class="img_container">');
					HTP.P('<img src="'||FUN.GETPROP(PRM_OBJETO,'IMG')||'" />');
				HTP.P('</div>');
			END IF;
		
			HTP.P('<div class="data_container '||WS_CLASS||'">');

				OBJ.TITULO(PRM_OBJETO, PRM_DRILL, PRM_DESC, PRM_SCREEN, WS_VALOR_PONTO, PRM_PARAMETROS, WS_USUARIO);

				WS_COUNT := 0;

				WS_COMPLEMENTO := '';

				BEGIN
					FOR I IN(SELECT RTRIM(CD_COLUNA)||'|'||DECODE(RTRIM(CONDICAO),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]')||TRIM(CONTEUDO) AS COLUNA FROM FILTROS WHERE TRIM(MICRO_VISAO) = TRIM(PRM_VISAO) AND TRIM(CD_OBJETO) = TRIM(PRM_OBJETO) AND TP_FILTRO = 'objeto') LOOP
						WS_FILTRO := I.COLUNA||'|'||WS_FILTRO;
					END LOOP;

					WS_COMPLEMENTO := ' data-filtro="'||WS_FILTRO||'" onclick="get(''drill_go'').value = ''''; drillfix(event, '''||PRM_OBJETO||''', this.getAttribute(''data-filtro''));"';

				EXCEPTION WHEN OTHERS THEN
					IF GBL.GETNIVEL = 'S' THEN
						HTP.P(SQLERRM);
					END IF;
				END;

				IF NVL(FUN.GETPROP(PRM_OBJETO,'META'), 'N/A') <> 'N/A' THEN
					HTP.P('<div id="ctnr_'||WS_OBJ||'" class="block-fusion"></div>');
				END IF;


				WS_MSG_DADOS := NVL(FUN.GETPROP(PRM_OBJETO,'ERR_SD'),'N/A'); -- adicionado para o usuário optar quando valor é nulo, colocar um valor desejado. 12/05/22


				HTP.P('<div class="valor" id="'||WS_OBJ||'_vl" '||WS_COMPLEMENTO||'>');

					WS_VALOR_UM := FUN.GETPROP(TRIM(PRM_OBJETO),'UM');

                    IF INSTR(WS_VALOR_UM, '<') = 1 THEN
					    HTP.PRN(REPLACE(WS_VALOR_UM, '<', ''));
					END IF;


					HTP.PRN(FUN.UM(SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1),PRM_VISAO, NVL(FUN.IFMASCARA(WS_VALOR_PONTO, RTRIM(WS_MASCARA), PRM_VISAO, SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1), PRM_OBJETO, '', WS_FORMULA, PRM_SCREEN, WS_USUARIO), WS_MSG_DADOS)));


                    IF INSTR(WS_VALOR_UM, '>') = 1 THEN
					    HTP.PRN(REPLACE(WS_VALOR_UM, '>', ''));
					END IF;

				HTP.P('</div>');

				-- Adicionado Style para aplicar o DESTAQUE no valor também quando parametrizado (criado novo atributo) - 26/01/2022 - Ivanor 
				if nvl(ws_aplica_destaque,' ') not in ('valor','ambos') then 
	   				ws_blink := ' ';
	            else    
					ws_blink := fun.check_blink(prm_objeto, substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), NVL(ws_valor_ponto, 'N/A'), ws_prop_color, prm_screen, ws_usuario);
				end if; 
				if nvl(ws_blink, 'N/A') = 'N/A' then
        		   ws_blink := ' ';
				end if;
                if nvl(ws_aplica_destaque,' ') in ('valor','ambos') then 
					htp.prn('<style> div#'||trim(ws_obj)||'_vl { '||ws_blink||'; } </style>');
				end if;


				WS_VALOR_META := FUN.CONVERT_PAR(FUN.GETPROP(TRIM(PRM_OBJETO),'META'), PRM_SCREEN => PRM_SCREEN);
		
				IF WS_COUNT_META <> 0 THEN
					WS_VALOR_META := WS_VALOR_PONTO;
				END IF;

				WS_COMPLEMENTO := FUN.IFMASCARA(WS_VALOR_META, RTRIM(WS_MASCARA), PRM_VISAO, SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1), PRM_OBJETO, '', WS_FORMULA, PRM_SCREEN, WS_USUARIO);

				IF LENGTH(WS_VALOR_META) > 0 THEN
					HTP.P('<div id="'||WS_OBJ||'_mt">'||FUN.GETPROP(TRIM(PRM_OBJETO),'META_HINT')||' '||WS_COMPLEMENTO||'</div>');
				END IF;

				IF WS_COUNT_META <> 0 THEN
					WS_COMPLEMENTO := WS_VALOR_PONTO;
				ELSE
					WS_COMPLEMENTO := FUN.GETPROP(TRIM(PRM_OBJETO),'META');
				END IF;

				HTP.P('<span id="valores_'||WS_OBJ||'" data-tipo="VALOR" data-valor="'||WS_VALOR_PONTO||'" data-color="'||FUN.GETPROP(PRM_OBJETO,'COLOR')||'" data-meta="'||FUN.CONVERT_PAR(WS_COMPLEMENTO, PRM_SCREEN => PRM_SCREEN)||'" data-colunareal="'||PRM_PARAMETROS||'" data-coluna="'||REPLACE(FUN.CHECK_ROTULOC(SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1), PRM_VISAO, PRM_SCREEN), '<BR>', ' ')||'"></span>');

			HTP.P('</div>');	
			
		HTP.P('</div>');

	END IF;
EXCEPTION 
	WHEN WS_ERROR THEN
		INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - ESTRUTURA', WS_USUARIO, 'ERRO');
		COMMIT;
	WHEN OTHERS THEN
		INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - ERROR', WS_USUARIO, 'ERRO');
		COMMIT;
END VALOR;

PROCEDURE PONTEIRO ( PRM_OBJETO      VARCHAR2 DEFAULT NULL,
					 PRM_DRILL       VARCHAR2 DEFAULT NULL,
					 PRM_DESC        VARCHAR2 DEFAULT NULL,
					 PRM_VISAO       VARCHAR2 DEFAULT NULL,
					 PRM_PARAMETROS  VARCHAR2 DEFAULT NULL,
					 PRM_PROPAGATION VARCHAR2 DEFAULT NULL,
					 PRM_SCREEN      VARCHAR2 DEFAULT NULL,
					 PRM_POSX        VARCHAR2 DEFAULT NULL,
					 PRM_POSY        VARCHAR2 DEFAULT NULL,
                     PRM_POSICAO     VARCHAR2 DEFAULT NULL ) AS

    WS_MASCARA         VARCHAR2(100);
    WS_UNIDADE         VARCHAR2(100);
    WS_FORMULA         VARCHAR2(3000);
    WS_OBJ             VARCHAR2(100);
    WS_FILTRO          VARCHAR2(2000);
    WS_CLASS           VARCHAR2(60);
    WS_GRADIENTE       VARCHAR2(2000);
    WS_GRADIENTE_T     VARCHAR2(40);
    WS_COMPLEMENTO     VARCHAR2(1400) := '';
    WS_GOTO            VARCHAR2(2000);
    WS_COUNT           NUMBER;
	WS_VALOR_PONTO     VARCHAR2(80);
	WS_USUARIO         VARCHAR2(40);
	WS_ARR             ARR;

	WS_PROP_ALTURA    VARCHAR2(80);
	WS_PROP_BGCOLOR   VARCHAR2(80);
	WS_PROP_BOLD      VARCHAR2(80);
	WS_PROP_COLOR     VARCHAR2(80);
	WS_PROP_DEGRADE   VARCHAR2(80);
	WS_PROP_DEGRADETP VARCHAR2(80);
	WS_PROP_FONT      VARCHAR2(80);
	WS_PROP_IT     	  VARCHAR2(80);
	WS_PROP_LARGURA   VARCHAR2(80);
	WS_PROP_NORADIUS  VARCHAR2(80);
	WS_PROP_SIZE      VARCHAR2(80);
	WS_PROP_TITBG     VARCHAR2(80);
	WS_PROP_UM        VARCHAR2(80);
	WS_PROP_BORDA	  VARCHAR2(80);

BEGIN

    WS_USUARIO := GBL.GETUSUARIO;

	WS_ARR := FUN.GETPROPS(PRM_OBJETO, 'PONTEIRO', 'ALTURA|BGCOLOR|BOLD|BORDA_COR|COLOR|DEGRADE|DEGRADE_TIPO|FONT|IT|LARGURA|NO_RADIUS|SIZE|TIT_BGCOLOR|UM', 'DWU');

	WS_PROP_ALTURA    := WS_ARR(1);
	WS_PROP_BGCOLOR   := WS_ARR(2);
	WS_PROP_BOLD      := WS_ARR(3);
	WS_PROP_BORDA     := WS_ARR(4);
	WS_PROP_COLOR     := WS_ARR(5);

	WS_PROP_DEGRADE   := WS_ARR(6);
	WS_PROP_DEGRADETP := WS_ARR(7);
	WS_PROP_FONT      := WS_ARR(8);
	WS_PROP_IT     	  := WS_ARR(9);

	WS_PROP_LARGURA   := WS_ARR(10);
	WS_PROP_NORADIUS  := WS_ARR(11);
	WS_PROP_SIZE      := WS_ARR(12);

	WS_PROP_TITBG     := WS_ARR(13);
	WS_PROP_UM        := WS_ARR(14);

    SELECT NM_MASCARA, NM_UNIDADE, FORMULA INTO WS_MASCARA, WS_UNIDADE, WS_FORMULA
	FROM MICRO_COLUNA
	WHERE CD_MICRO_VISAO = PRM_VISAO AND
	CD_COLUNA = SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1);

	SELECT COUNT(*) INTO WS_COUNT FROM COLUMN_RESTRICTION WHERE USUARIO = USER AND CD_MICRO_VISAO = PRM_VISAO AND CD_COLUNA IN (SELECT COLUMN_VALUE FROM TABLE(FUN.VPIPE(PRM_PARAMETROS)));

    IF WS_COUNT = 0 THEN

		WS_OBJ := TRIM(PRM_OBJETO);

		IF  PRM_DRILL = 'Y' THEN
			WS_OBJ := TRIM(PRM_OBJETO)||'trl';
		END IF;

		WS_GRADIENTE := 'background-color: '||WS_PROP_BGCOLOR;

		IF WS_PROP_DEGRADE = 'S' THEN

            IF NVL(WS_PROP_DEGRADETP, '%??%') = '%??%' THEN
				WS_GRADIENTE_T := 'linear';
			ELSE
				WS_GRADIENTE_T := WS_PROP_DEGRADETP;
			END IF;

            WS_GRADIENTE := ' background: '||WS_GRADIENTE_T||'-gradient('||WS_PROP_TITBG||', '||WS_PROP_BGCOLOR||'); ';
		END IF;

		HTP.P('<div id="'||WS_OBJ||'" class="dragme medidor'||WS_CLASS||'" onmousedown="'||PRM_PROPAGATION||'">');

		    HTP.P('<style>div#'||WS_OBJ||' { '||PRM_POSICAO||' '||WS_GRADIENTE||'; border: 1px solid '||WS_PROP_BORDA||'; }</style>');

			SELECT COUNT(CD_OBJETO_GO) INTO WS_COUNT FROM GOTO_OBJETO WHERE CD_OBJETO = RTRIM(PRM_OBJETO);

			HTP.P('<div id="dados_'||WS_OBJ||'" style="display: none;" data-visao="'||PRM_VISAO||'" data-tipo="PONTEIRO" data-swipe="" data-width="'||WS_PROP_LARGURA||'" data-height="'||WS_PROP_ALTURA||'" data-top="'||PRM_POSY||'" data-left="'||PRM_POSX||'" data-drill="'||WS_COUNT||'"></div>');

			IF FUN.GETPROP(PRM_OBJETO,'NO_RADIUS') <> 'N' THEN
				HTP.P('<style>div#'||WS_OBJ||', div#'||WS_OBJ||'_ds { border-radius: 0; } div#'||WS_OBJ||' /*span#'||WS_OBJ||'more { border-radius: 0 0 6px 0; }*/ a#'||WS_OBJ||'fechar { border-radius: 0 0 0 6px; }</style>');
			END IF;

			OBJ.OPCOES(WS_OBJ, 'PONTEIRO', PRM_PARAMETROS, PRM_VISAO, PRM_SCREEN, PRM_DRILL, PRM_USUARIO => WS_USUARIO);

			OBJ.TITULO(PRM_OBJETO, PRM_DRILL, PRM_DESC, PRM_SCREEN, WS_USUARIO);

			HTP.PRN('<ul id="'||WS_OBJ||'-filterlist" style="display: none;">');
				HTP.PRN(FUN.SHOW_FILTROS(PRM_PARAMETROS, '', '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN));
			HTP.PRN('</ul>');

			HTP.PRN('<style>div#ctnr_'||WS_OBJ||' {');
				HTP.PRN('position: relative !important;');
				HTP.PRN('max-width: inherit;'); 
				HTP.PRN('min-width: inherit;'); 
				HTP.PRN('width: '||WS_PROP_LARGURA||'px;'); 
				HTP.PRN('height: '||WS_PROP_ALTURA||'px;');
			HTP.PRN('}</style>');

			HTP.P('<div id="ctnr_'||WS_OBJ||'" class="block-fusion">'||FUN.LANG('Carregando Informa&ccedil;&otilde;es...Aguarde!')||'</div>');

				WS_VALOR_PONTO := FUN.VALOR_PONTO(PRM_PARAMETROS, PRM_VISAO, PRM_OBJETO, PRM_SCREEN );

				HTP.P('<div id="valor_'||WS_OBJ||'" title="'||WS_VALOR_PONTO||'" onclick="get(''drill_go'').value = ''''; drillfix(event, '''||PRM_OBJETO||''', '''');" style="cursor: pointer;">');

				IF(INSTR(WS_PROP_UM, '>') = 1) THEN
					HTP.PRN(FUN.UM(SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1), PRM_VISAO,NVL(FUN.IFMASCARA(WS_VALOR_PONTO,RTRIM(WS_MASCARA), PRM_VISAO, SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1), PRM_OBJETO, '', WS_FORMULA, PRM_SCREEN, WS_USUARIO), 'N/A'))||' '||REPLACE(WS_PROP_UM, '>', ''));
				ELSIF(INSTR(WS_PROP_UM, '<') = 1) THEN
					HTP.PRN(REPLACE(WS_PROP_UM, '<', '')||' '||FUN.UM(SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1),PRM_VISAO,NVL(FUN.IFMASCARA(WS_VALOR_PONTO,RTRIM(WS_MASCARA), PRM_VISAO, SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1), PRM_OBJETO, '', WS_FORMULA, PRM_SCREEN, WS_USUARIO), 'N/A')));
				ELSE
					HTP.PRN(FUN.UM(SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1), PRM_VISAO,NVL(FUN.IFMASCARA(WS_VALOR_PONTO,RTRIM(WS_MASCARA), PRM_VISAO, SUBSTR(PRM_PARAMETROS, 1 ,INSTR(PRM_PARAMETROS,'|')-1), PRM_OBJETO, '', WS_FORMULA, PRM_SCREEN, WS_USUARIO), 'N/A')));
				END IF;

			HTP.P('</div>');

			HTP.P('<style>div#valor_'||WS_OBJ||' { overflow: hidden; height: 32px; line-height: 32px; border-top: 1px solid #000; text-align: center; font-style: '||WS_PROP_IT||'; font-weight: '||WS_PROP_BOLD||'; font-family: '||WS_PROP_FONT||'; font-size: '||WS_PROP_SIZE||'; color: '||WS_PROP_COLOR||'; }</style>');

			FCL.DATA_ATTRIB(WS_OBJ, 'PONTEIRO', PRM_SCREEN);

        HTP.P('</div>');

    END IF;

END PONTEIRO;

PROCEDURE GRAFICO ( PRM_OBJETO      VARCHAR2 DEFAULT NULL,
					PRM_DRILL       VARCHAR2 DEFAULT NULL,
					PRM_DESC        VARCHAR2 DEFAULT NULL,
					PRM_VISAO       VARCHAR2 DEFAULT NULL,
					PRM_PARAMETROS  VARCHAR2 DEFAULT NULL,
					PRM_PROPAGATION VARCHAR2 DEFAULT NULL,
					PRM_SCREEN      VARCHAR2 DEFAULT NULL,
					PRM_POSX        VARCHAR2 DEFAULT NULL,
					PRM_POSY        VARCHAR2 DEFAULT NULL,
                    PRM_BORDA       VARCHAR2 DEFAULT NULL,
                    PRM_POSICAO     VARCHAR2 DEFAULT NULL,
					PRM_DASHBOARD   VARCHAR2 DEFAULT NULL ) AS

    WS_TIPO            VARCHAR2(80);
	WS_GRADIENTE       VARCHAR2(2000);
	WS_GRADIENTE_TIPO  VARCHAR2(40);
	WS_POSICAO         VARCHAR2(80);
	WS_CLASS           VARCHAR2(60);
	WS_ALINHAMENTO_TIT VARCHAR2(80);
	WS_OBJ             VARCHAR2(400);
	WS_GOTO            VARCHAR2(2000);
	WS_FILTRO          VARCHAR2(2000);
	WS_COLUNA          VARCHAR2(400) := '';
	WS_AGRUPADOR       VARCHAR2(400) := '';
	WS_COLUP           VARCHAR2(400) := '';
	
	WS_PARAMETROSR     CLOB;
	WS_PARAMETROS      CLOB;
	WS_COUNT           NUMBER;

	WS_PROP_DEGRADE       VARCHAR2(40);
    WS_PROP_DEGRADE_TIPO  VARCHAR2(40);
	WS_PROP_TIT_BG        VARCHAR2(40);
	WS_PROP_BG            VARCHAR2(40);
	WS_PROP_RADIUS        VARCHAR2(40);
	WS_PROP_LARGURA       VARCHAR2(40);
	WS_PROP_ALTURA        VARCHAR2(40);
	WS_PROP_ALIGN_TIT     VARCHAR2(40);
	WS_PROP_SEC           VARCHAR2(120);
	WS_PROP_BORDA         VARCHAR2(40);
	WS_USUARIO            VARCHAR2(40);
	WS_PADRAO			  VARCHAR2(80);      

	WS_ARR ARR;
BEGIN

    WS_USUARIO := GBL.GETUSUARIO;
	WS_PADRAO  := GBL.GETLANG;

	
    SELECT DECODE(TP_OBJETO, 'OBJETO', 'BARRAS', TP_OBJETO) INTO WS_TIPO FROM OBJETOS WHERE CD_OBJETO = PRM_OBJETO;
	SELECT CS_COLUNA, CS_AGRUPADOR, NVL(CS_COLUP, '') INTO WS_COLUNA, WS_AGRUPADOR, WS_COLUP FROM PONTO_AVALIACAO WHERE CD_PONTO = PRM_OBJETO;
	SELECT COUNT(*) INTO WS_COUNT FROM GOTO_OBJETO WHERE CD_OBJETO = PRM_OBJETO;

	WS_ARR := FUN.GETPROPS(PRM_OBJETO, WS_TIPO, 'ALIGN_TIT|ALTURA|BGCOLOR|BORDA_COR|DEGRADE|DEGRADE_TIPO|LARGURA|NO_RADIUS|TIT_BGCOLOR', 'DWU');

    WS_PROP_ALIGN_TIT    := WS_ARR(1);
	WS_PROP_ALTURA       := WS_ARR(2);
	WS_PROP_BG           := WS_ARR(3);
	WS_PROP_BORDA        := WS_ARR(4);
	WS_PROP_DEGRADE      := WS_ARR(5);
	WS_PROP_DEGRADE_TIPO := WS_ARR(6);
	WS_PROP_LARGURA      := WS_ARR(7);
	WS_PROP_RADIUS       := WS_ARR(8);
	WS_PROP_TIT_BG       := WS_ARR(9);

	WS_PROP_SEC          := FUN.GETPROP(PRM_OBJETO, 'SEC');

	IF PRM_DRILL = 'Y' THEN
		WS_CLASS := ' drill';
	END IF;

	IF WS_TIPO = 'MAPA' THEN
		WS_CLASS := WS_CLASS||' mapa';
	END IF;

	IF TRIM(WS_PROP_DEGRADE) = 'S' THEN
		IF NVL(WS_PROP_DEGRADE_TIPO, '%??%') = '%??%' THEN
			WS_GRADIENTE_TIPO := 'linear';
		ELSE
			WS_GRADIENTE_TIPO := WS_PROP_DEGRADE_TIPO;
		END IF;
		
		WS_GRADIENTE := 'background: '||WS_GRADIENTE_TIPO||'-gradient('||WS_PROP_TIT_BG||', '||WS_PROP_BG||');';
	ELSE
		WS_GRADIENTE := 'background: '||WS_PROP_BG||';';
	END IF;

	WS_PARAMETROSR := REPLACE(PRM_PARAMETROS, '  |  ', '');

	IF FUN.SETEM(WS_PARAMETROS,'|') AND NVL(TRIM(WS_PARAMETROSR),'%$%')<>'%$%' THEN
		WS_PARAMETROS := WS_PARAMETROS||WS_PARAMETROSR;
	ELSE
		WS_PARAMETROS := WS_PARAMETROSR;
	END IF;
						
	IF PRM_DRILL = 'Y' THEN
		WS_OBJ := PRM_OBJETO||'trl';
	ELSE
		WS_OBJ := PRM_OBJETO;
	END IF;
						
	FOR I IN(SELECT RTRIM(CD_COLUNA)||'|'||DECODE(RTRIM(CONDICAO),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]')||RTRIM(CONTEUDO) AS COLUNA FROM FILTROS WHERE TRIM(MICRO_VISAO) = TRIM(PRM_VISAO) AND TP_FILTRO = 'objeto' AND TRIM(CD_OBJETO) IN (TRIM(PRM_OBJETO)) AND TRIM(CD_USUARIO)  = 'DWU') LOOP
		WS_FILTRO := I.COLUNA||'|'||WS_FILTRO;
	END LOOP;

	
	
	WS_FILTRO := SUBSTR(WS_FILTRO, 0, LENGTH(WS_FILTRO)-1);
	
	WS_FILTRO := WS_FILTRO||'|'||PRM_PARAMETROS;
							
	HTP.P('<div class="dragme grafico'||WS_CLASS||'" onclick="if(objatual != this.id){ objatual = this.id;}" id="'||WS_OBJ||'" onmousedown="'||PRM_PROPAGATION||'">');

	HTP.P('<style>div#'||WS_OBJ||' { '||WS_GRADIENTE||' '||PRM_BORDA||' '||PRM_POSICAO||'; border: 1px solid '||WS_PROP_BORDA||'; }</style>');
	
	IF WS_PROP_RADIUS <> 'N' THEN
		HTP.P('<style>div#'||PRM_OBJETO||', div#'||PRM_OBJETO||'_ds { border-radius: 0; } div#'||PRM_OBJETO||' /*span#'||PRM_OBJETO||'more { border-radius: 0 0 6px 0; }*/ a#'||PRM_OBJETO||'fechar { border-radius: 0 0 0 6px; }</style>');
	END IF;

	OBJ.OPCOES(WS_OBJ, WS_TIPO, WS_PARAMETROS, PRM_VISAO, PRM_SCREEN, PRM_DRILL, WS_AGRUPADOR, WS_COLUP, PRM_USUARIO => WS_USUARIO);

	IF PRM_DRILL = 'Y' THEN
		IF LOWER(WS_PROP_LARGURA) = 'auto' THEN
			WS_POSICAO := 'width: 400px; height: '||WS_PROP_ALTURA||'px;';
		ELSE
			WS_POSICAO := 'width: '||WS_PROP_LARGURA||'px; height: '||WS_PROP_ALTURA||'px;';
		END IF;
	ELSE
		WS_POSICAO := 'width: '||WS_PROP_LARGURA||'px; height: '||WS_PROP_ALTURA||'px;';
	END IF;

	SELECT COUNT(*) INTO WS_COUNT FROM GOTO_OBJETO WHERE CD_OBJETO = PRM_OBJETO;
						
	
	
    
	HTP.P('<div data-tipoobj="'||WS_TIPO||'" id="dados_'||TRIM(WS_OBJ)||'" data-visao="'||PRM_VISAO||'" data-heatmap="'||FUN.GETPROP(PRM_OBJETO, 'HEATMAP')||'" data-funil-sort="'||FUN.GETPROP(PRM_OBJETO, 'FUNIL_SORT')||'" data-funil="'||FUN.GETPROP(PRM_OBJETO, 'FUNIL')||'"  data-ccoluna-hex="'||FUN.GETPROP(PRM_OBJETO, 'COR-COLUNA-HEX')||'" data-maximo="'||FUN.XFORMULA(FUN.GETPROP(PRM_OBJETO, 'MAXIMO'), PRM_SCREEN)||'"  data-filtro="'||WS_FILTRO||'" data-drill="'||WS_COUNT||'" data-sec="'||FUN.CHECK_ROTULOC(WS_PROP_SEC, PRM_VISAO)||'" data-coluna="'||FUN.UTRANSLATE('NM_ROTULO', PRM_VISAO, FUN.CHECK_ROTULOC(WS_COLUNA, PRM_VISAO), WS_PADRAO)||'" data-colunareal="'||WS_COLUNA||'" data-agrupadoresreal="'||WS_AGRUPADOR||'" data-agrupadores="'||FUN.UTRANSLATE('NM_ROTULO', PRM_VISAO, FUN.CHECK_ROTULOC(WS_AGRUPADOR, PRM_VISAO), WS_PADRAO)||'" data-tipo="'||WS_TIPO||'" data-top="'||PRM_POSY||'" data-left="'||PRM_POSX||'" data-swipe="" style="display: none;"></div>');

	IF INSTR(WS_TIPO, 'MAPA') > 0 THEN
		IF FUN.GETPROP(PRM_OBJETO, 'TYPE') = 'C' THEN
			HTP.P('<ul class="lista_cidades" style="display: none; white-space: nowrap; word-break: keep-all;">');
				FCL.LISTA_CIDADES(FUN.GETPROP(PRM_OBJETO, 'ESTADOS'), 'CD', PRM_OBJETO, PRM_SCREEN, PRM_VISAO, PRM_PARAMETROS);
			HTP.P('</ul>');
		ELSE
			HTP.P('<ul class="lista_estados" style="display: none; white-space: nowrap; word-break: keep-all;">');
				FCL.LISTA_ESTADOS(FUN.GETPROP(PRM_OBJETO, 'ESTADOS'), 'CD', PRM_OBJETO, PRM_SCREEN, PRM_VISAO, PRM_PARAMETROS);
			HTP.P('</ul>');
		END IF;
	END IF;

	OBJ.TITULO(PRM_OBJETO, PRM_DRILL, PRM_DESC, PRM_SCREEN, WS_USUARIO);

	WS_COUNT := 0;
	
	IF WS_TIPO <> 'MAPA' THEN
	
		HTP.P('<select class="ordem" onchange="call(''alter_attrib'', ''prm_objeto='||PRM_OBJETO||'&prm_prop=ORDEM&prm_value=''+this.value+''&prm_usuario='||WS_USUARIO||''').then(function(res){ if(res.indexOf(''alert'') == -1){ renderChartDirect('''||PRM_OBJETO||'''); } });">');
			HTP.P('<option selected disabled>Ordem do gr&aacute;fico</option>');


			
			-- TROCADO O LEFT JOIN POR RIGHT JOIN PELO FATO DA ORDEM ESTA SE PERDENDO QUANDO CHEGA NO PIVOT, INVERTENDO AS POSIÇÕES 18/02/2022
			FOR I IN(
				SELECT COLUMN_VALUE AS COLUNA, CD_LIGACAO AS LIGACAO 
				FROM TABLE(FUN.VPIPE(WS_COLUNA||'|'||WS_AGRUPADOR||'|'||WS_COLUP||'|'||FUN.GETPROP(PRM_OBJETO, 'SEC'))) T1
				RIGHT JOIN MICRO_COLUNA T2 ON T2.CD_COLUNA = T1.COLUMN_VALUE AND T2.CD_MICRO_VISAO = PRM_VISAO
				WHERE COLUMN_VALUE IS NOT NULL
			) LOOP
				WS_COUNT := WS_COUNT+1;
				HTP.P('<option value="'||WS_COUNT||' ASC">'||FUN.CHECK_ROTULOC(I.COLUNA, PRM_VISAO, PRM_SCREEN)||' crescente</option>');
				HTP.P('<option value="'||WS_COUNT||' DESC">'||FUN.CHECK_ROTULOC(I.COLUNA, PRM_VISAO, PRM_SCREEN)||' decrescente</option>');
				IF WS_COUNT = 1 AND I.LIGACAO <> 'SEM' THEN
					WS_COUNT := WS_COUNT+1;
					HTP.P('<option value="'||WS_COUNT||' ASC">'||FUN.CHECK_ROTULOC(I.COLUNA, PRM_VISAO, PRM_SCREEN)||'(desc) crescente</option>');
					HTP.P('<option value="'||WS_COUNT||' DESC">'||FUN.CHECK_ROTULOC(I.COLUNA, PRM_VISAO, PRM_SCREEN)||'(desc) decrescente</option>');
				END IF;
			END LOOP;
		HTP.P('</select>');

		

	END IF;

	HTP.PRN('<ul id="'||WS_OBJ||'-filterlist" style="display: none;">');
		HTP.PRN(FUN.SHOW_FILTROS(WS_PARAMETROS, '', '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN));
	HTP.PRN('</ul>');

	HTP.PRN('<ul id="'||WS_OBJ||'-destaquelist" style="display: none;" >');
		HTP.PRN(FUN.SHOW_DESTAQUES(WS_PARAMETROS, '', '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN));
	HTP.PRN('</ul>');

	HTP.P('<div style="display: none;" id="gxml_'||WS_OBJ||'" data-parametros="'||WS_PARAMETROS||'" data-cs_coluna="'||WS_COLUP||'" data-cs_agrupador="'||WS_AGRUPADOR||'" data-tip="'||WS_TIPO||'" data-cs_colup="'||WS_COLUP||'" data-sec="'||WS_PROP_SEC||'">');
	    FCL.CHAROUT(WS_PARAMETROS, PRM_VISAO, REPLACE(WS_OBJ, 'trl', ''), PRM_SCREEN);
	HTP.P('</div>');

		IF WS_TIPO IN ('LINHAS', 'BARRAS') THEN
			HTP.P('<div class="espaco" style="-webkit-overflow-scrolling: touch; overflow-x: auto; height: calc('||WS_PROP_ALTURA||'px + 20px);"><div id="ctnr_'||WS_OBJ||'" class="block-fusion" style="position: relative !important; min-width: inherit; '||WS_POSICAO||'">'||FUN.LANG('Carregando Informa&ccedil;&otilde;es...Aguarde!')||'</div></div>');
		ELSE
			HTP.P('<div id="ctnr_'||WS_OBJ||'" class="block-fusion espaco" style="position: relative !important; min-width: inherit; max-width: inherit; '||WS_POSICAO||'">'||FUN.LANG('Carregando Informa&ccedil;&otilde;es...Aguarde!')||'</div>');
		END IF;
	                        
		FCL.DATA_ATTRIB(WS_OBJ, WS_TIPO, PRM_SCREEN);

	HTP.P('</div>');
EXCEPTION WHEN OTHERS THEN
	HTP.P(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END GRAFICO;

PROCEDURE RELATORIO ( PRM_OBJETO      VARCHAR2 DEFAULT NULL,
					  PRM_PROPAGATION VARCHAR2 DEFAULT NULL,
					  PRM_SCREEN      VARCHAR2 DEFAULT NULL,
					  PRM_DRILL       VARCHAR2 DEFAULT NULL,
					  PRM_NOME        VARCHAR2 DEFAULT NULL,
					  PRM_POSICAO     VARCHAR2 DEFAULT NULL,
					  PRM_POSY        VARCHAR2 DEFAULT NULL,
					  PRM_POSX        VARCHAR2 DEFAULT NULL  ) AS 

    WS_USUARIO VARCHAR2(40);
	WS_OBJ   VARCHAR2(80);
	WS_STYLE VARCHAR2(80);
	WS_PROPS_BORDA VARCHAR2(80);
	WS_COUNT NUMBER;

BEGIN

    WS_USUARIO := GBL.GETUSUARIO;

    IF  PRM_DRILL='Y' THEN
		WS_OBJ := PRM_OBJETO||'trl';
	ELSE
		WS_OBJ := PRM_OBJETO;
	END IF;

	WS_PROPS_BORDA := FUN.GETPROP(WS_OBJ, 'BORDA_COR');

	HTP.P('<div onmousedown="'||PRM_PROPAGATION||'" id="'||TRIM(WS_OBJ)||'" data-top="'||PRM_POSY||'" data-left="'||PRM_POSX||'" style="'||PRM_POSICAO||'; border: 1px solid '||WS_PROPS_BORDA||'; width: 280px; background-color: #FFF; border: 1px solid #999; text-align: center;" class="dragme relatorio">');

		OBJ.OPCOES(WS_OBJ, 'RELATORIO', '', '', PRM_SCREEN, PRM_DRILL, PRM_USUARIO => WS_USUARIO);

		IF INSTR(FUN.GETPROP(WS_OBJ, 'LARGURA'), '%') > 0 THEN
			WS_STYLE := FUN.GETPROP(WS_OBJ, 'LARGURA');
		ELSE
			WS_STYLE := REPLACE(FUN.GETPROP(WS_OBJ, 'LARGURA'), 'px', '')||'px';
		END IF;
		
		OBJ.TITULO(PRM_OBJETO, PRM_DRILL, PRM_NOME, PRM_SCREEN, WS_USUARIO);

		SELECT COUNT(*) INTO WS_COUNT FROM TAB_DOCUMENTOS WHERE TRIM(NAME) LIKE 'REL_'||PRM_OBJETO||'_'||GBL.GETUSUARIO||'_%' AND CONTENT_TYPE = 'LOCKED';
		
		HTP.P('<ul id="'||TRIM(PRM_OBJETO)||'_lista">');
			IF WS_COUNT <> 0 THEN
				UP_REL.BAIXAR_REL(PRM_OBJETO, 'LOCKED');
			ELSE
				UP_REL.BAIXAR_REL(PRM_OBJETO);
			END IF;
		HTP.P('</ul>');

		IF WS_COUNT <> 0 THEN
			HTP.P('<a class="rel_button loading" id="'||PRM_OBJETO||'_button" onclick="gerar_relatorio('''||PRM_OBJETO||''', '''||PRM_SCREEN||''', '''||TO_CHAR(SYSDATE, 'YYMMDDHH24MI')||''');">');
				HTP.P('<span>'||FUN.LANG('EXECUTANDO')||'</span>');
			HTP.P('</a>');
		ELSE
			HTP.P('<a class="rel_button" id="'||PRM_OBJETO||'_button" onclick="gerar_relatorio('''||PRM_OBJETO||''', '''||PRM_SCREEN||''', '''||TO_CHAR(SYSDATE, 'YYMMDDHH24MI')||''');">');
				HTP.P('<span>'||FUN.LANG('GERAR RELAT&Oacute;RIO')||'</span>');
			HTP.P('</a>');
		END IF;
	HTP.P('</div>');

END RELATORIO;

PROCEDURE FILE ( PRM_OBJETO      VARCHAR2 DEFAULT NULL,
                 PRM_PROPAGATION VARCHAR2 DEFAULT NULL,
				 PRM_SCREEN      VARCHAR2 DEFAULT NULL,
				 PRM_DRILL       VARCHAR2 DEFAULT NULL,
				 PRM_NOME        VARCHAR2 DEFAULT NULL,
				 PRM_POSICAO     VARCHAR2 DEFAULT NULL,
				 PRM_POSY        VARCHAR2 DEFAULT NULL,
				 PRM_POSX        VARCHAR2 DEFAULT NULL ) AS 

    WS_BORDA     VARCHAR2(80);
    WS_WIDTH     VARCHAR2(80);
	WS_HEIGHT    VARCHAR2(80);
    WS_BG        VARCHAR2(80);
	WS_ALIGN_TIT VARCHAR2(80);
	WS_COLOR_TIT VARCHAR2(80);
	WS_BG_TIT    VARCHAR2(80);
	WS_IT_TIT    VARCHAR2(80);
	WS_BOLD_TIT	 VARCHAR2(80);
	WS_FONT_TIT	 VARCHAR2(80);
	WS_SIZE_TIT	 VARCHAR2(80);

	WS_SANDBOX   VARCHAR2(20);
	WS_USUARIO   VARCHAR2(80);
	WS_ATRIBUTOS VARCHAR2(120);
	WS_COUNT     NUMBER := 0;

BEGIN

    WS_USUARIO := GBL.GETUSUARIO;

    SELECT ATRIBUTOS INTO WS_ATRIBUTOS
	FROM   OBJETOS
	WHERE  CD_OBJETO=PRM_OBJETO;
    
	
	WS_BORDA     := 'border-color: '||FUN.GETPROP(PRM_OBJETO, 'BORDA_COR');
    WS_WIDTH     := 'width: '||FUN.GETPROP(PRM_OBJETO, 'LARGURA');
	WS_HEIGHT    := 'height: '||FUN.GETPROP(PRM_OBJETO, 'ALTURA');
    WS_BG        := 'background: '||NVL(FUN.GETPROP(PRM_OBJETO, 'BGCOLOR'), '#FFF');
	WS_ALIGN_TIT := 'text-align: '||FUN.GETPROP(PRM_OBJETO,'ALIGN_TIT');
	WS_COLOR_TIT := 'color: '||FUN.GETPROP(PRM_OBJETO, 'TIT_COLOR');
	WS_BG_TIT    := 'background: '||FUN.GETPROP(PRM_OBJETO, 'TIT_BGCOLOR');
	WS_IT_TIT    := 'text-decotarion: '||FUN.GETPROP(PRM_OBJETO, 'TIT_IT');
	WS_BOLD_TIT	 := 'font-weight: '||FUN.GETPROP(PRM_OBJETO, 'TIT_BOLD');
	WS_FONT_TIT	 := 'font-family: '||FUN.GETPROP(PRM_OBJETO, 'TIT_FONT');
	WS_SIZE_TIT	 := 'font-size: '||FUN.GETPROP(PRM_OBJETO, 'TIT_SIZE');

	HTP.P('<div onmousedown="'||PRM_PROPAGATION||'" id="'||PRM_OBJETO||'" data-top="'||PRM_POSY||'" data-left="'||PRM_POSX||'" class="dragme file drill_'||PRM_DRILL||' radius_'||FUN.GETPROP(PRM_OBJETO,'NO_RADIUS')||'">');
    
	
	HTP.PRN('<style> div#'||PRM_OBJETO||' {
	'||WS_BORDA||';
	'||WS_WIDTH||';
	'||WS_HEIGHT||';
	'||WS_BG||';
	'||PRM_POSICAO||';
    } 

	div#'||PRM_OBJETO||'.radius_S, div#'||PRM_OBJETO||'.radius_S div#'||PRM_OBJETO||'_ds { 
		border-radius: 0; 
	} 

	/*div#'||PRM_OBJETO||'.radius_S span#'||PRM_OBJETO||'more { 
		border-radius: 0 0 6px 0; 
	} */

	div#'||PRM_OBJETO||'.radius_S a#'||PRM_OBJETO||'fechar { 
		border-radius: 0 0 0 6px; 
	}

	div#'||PRM_OBJETO||'_ds {
        cursor: move; 
		text-align: center; 
		margin: 0 -3px; 
		padding: 3px; 
		'||WS_COLOR_TIT||';
		'||WS_BG_TIT||';
		'||WS_IT_TIT||';
		'||WS_BOLD_TIT||';
		'||WS_FONT_TIT||';
		'||WS_SIZE_TIT||';
	}

	div#'||PRM_OBJETO||'_sub {
        '||WS_ALIGN_TIT||';
		'||WS_COLOR_TIT||';
	} 
	div#'||PRM_OBJETO||'_vl {
        width: inherit; 
		height: inherit; 
		border: 0px; 
		padding: 0px; 
		overflow: auto; 
		top: 0;
		position: absolute; 
		background-color: #FFF; 
		z-index: -1;
	}
	div#'||PRM_OBJETO||'_sub a {
        right: 2px; 
		bottom: 2px; 
		position: absolute; 
		z-index: 2;
	}
	div#'||PRM_OBJETO||'_sub a img {
        height: 14px;
	}
	</style>');


	OBJ.OPCOES(PRM_OBJETO, 'FILE', '', '', PRM_SCREEN, PRM_DRILL, PRM_USUARIO => WS_USUARIO);
	
	OBJ.TITULO(PRM_OBJETO, PRM_DRILL, PRM_NOME, PRM_SCREEN, WS_USUARIO);

		IF FUN.GETPROP(PRM_OBJETO, 'SANDBOX') <> 'N' THEN
			WS_SANDBOX := 'sandbox';
		ELSE
			WS_SANDBOX := '';
		END IF;
			
		SELECT COUNT(*) INTO WS_COUNT FROM TAB_DOCUMENTOS WHERE NAME = REPLACE(WS_ATRIBUTOS, ' ', '_');
		IF WS_COUNT <> 0 THEN
			HTP.P('<a href="dwu.fcl.download?arquivo='||LOWER(REPLACE(WS_ATRIBUTOS, ' ', '_'))||'" download target="_blank">');
			    HTP.P('<img src="dwu.fcl.download?arquivo=download.png">');
			HTP.P('</a>');
			HTP.P( '<iframe '||WS_SANDBOX||' id="'||PRM_OBJETO||'_vl" onload="" name="'||PRM_OBJETO||'_file" onmousedown="event.stopPropagation();" src="dwu.fcl.download?arquivo='||REPLACE(WS_ATRIBUTOS, ' ', '_')||'">');
		ELSE
			HTP.P( '<iframe '||WS_SANDBOX||' id="'||PRM_OBJETO||'_vl" data-estilo="'||FUN.GETPROP(PRM_OBJETO,'CUSTOM_CSS')||'" onload="var estilo = document.createElement(''style''); estilo.innerHTML = this.getAttribute(''data-estilo''); document.getElementById('''||PRM_OBJETO||'_vl'').document.head.appendChild(estilo);" name="'||PRM_OBJETO||'_file" onmousedown="event.stopPropagation();" src="dwu.fcl.download?arquivo='||REPLACE(WS_ATRIBUTOS, ' ', '_')||'">');
		END IF;
		
		HTP.P('</iframe>');
		
	HTP.P('</div>');

END FILE;

PROCEDURE CONSULTA ( PRM_PARAMETROS	 VARCHAR2 DEFAULT NULL,
					 PRM_VISAO       VARCHAR2,
					 PRM_COLUNA	     VARCHAR2 DEFAULT NULL,
					 PRM_AGRUPADOR	 VARCHAR2 DEFAULT NULL,
					 PRM_RP		     VARCHAR2 DEFAULT 'ROLL',
					 PRM_COLUP	     VARCHAR2 DEFAULT NULL,
					 PRM_COMANDO	 VARCHAR2 DEFAULT 'MOUNT',
					 PRM_MODE	     VARCHAR2 DEFAULT 'NO',
					 PRM_OBJETO	     VARCHAR2,
					 PRM_SCREEN	     VARCHAR2 DEFAULT 'DEFAULT',
					 PRM_POSX	     VARCHAR2 DEFAULT NULL,
					 PRM_POSY	     VARCHAR2 DEFAULT NULL,
					 PRM_CCOUNT	     VARCHAR2 DEFAULT '0',
					 PRM_DRILL	     VARCHAR2 DEFAULT 'N',
					 PRM_ORDEM	     VARCHAR2 DEFAULT '0',
					 PRM_ZINDEX	     VARCHAR2 DEFAULT 'auto',
					 PRM_TRACK       VARCHAR2 DEFAULT NULL,
					 PRM_OBJETON     VARCHAR2 DEFAULT NULL,
					 PRM_SELF        VARCHAR2 DEFAULT NULL,
					 PRM_DASHBOARD   VARCHAR2 DEFAULT 'false',
					 PRM_PROPAGATION VARCHAR2 DEFAULT NULL ) AS

    WS_PROPAGATION VARCHAR2(400) := '';
	WS_SUBQUERY    VARCHAR2(600);
	WS_ISOLADO     VARCHAR2(60);
	WS_POSIX	   VARCHAR2(80);
	WS_POSIY	   VARCHAR2(80);
	WS_COD         VARCHAR2(80);
	WS_ORDER       VARCHAR2(90);
	WS_OBJ	       VARCHAR2(200);
	WS_COLUP	   VARCHAR2(400);
	WS_COLUNA	   VARCHAR2(400);
	WS_MODE		   VARCHAR2(30);
	WS_RP          VARCHAR2(80);
	WS_TEXTO       VARCHAR2(30000);
	WS_PARAMETROS  VARCHAR2(30000);
	WS_SEM		   VARCHAR2(40);
	WS_ORDEM	   VARCHAR2(400);
	WS_ORDEM_QUERY VARCHAR2(400);
	WS_TMP_JUMP	   VARCHAR2(300);
	WS_SHOW_ONLY   VARCHAR2(10);
	WS_FULL        VARCHAR2(10);
	WS_BORDA       VARCHAR2(60);
	WS_HTML        VARCHAR2(12000);
	WS_TITULO	   VARCHAR2(400);
	WS_BINDS       VARCHAR2(8000);
	WS_CTEMP	   VARCHAR2(40);
	WS_FIX         VARCHAR2(80);
	WS_USUARIO     VARCHAR2(80) := GBL.GETUSUARIO;
	WS_ADMIN       VARCHAR2(20) := GBL.GETNIVEL;
	
	WS_TPT         VARCHAR2(600);
	WS_QUERY_HINT  VARCHAR2(80);
	WS_CAB_CROSS   VARCHAR2(4000);
	WS_DRILL	   VARCHAR2(40);
	WS_SUBTITULO   VARCHAR2(400);
	WS_NOME        VARCHAR2(400);
	WS_JUMP		   VARCHAR2(600);
	RET_COLUNA	   VARCHAR2(4000);
	WS_ORDEM_ARROW VARCHAR2(100);
	WS_HINT        VARCHAR2(2000);
	WS_COL_SUP_ANT VARCHAR2(4000);
	WS_COL_SUP     VARCHAR2(4000);
	WS_CLASSE      VARCHAR2(400);
	WS_CALCULADA_N VARCHAR2(200);
	WS_ZEBRADO	   VARCHAR2(20);
	WS_ZEBRADO_D   VARCHAR2(40);
	WS_COD_COLUNA  VARCHAR2(2000);
	RET_COLGRP     VARCHAR2(2000);
	WS_DRILL_A	   VARCHAR2(4000);
	WS_LINHA_CALC  VARCHAR2(20);
	WS_CHECK       VARCHAR2(300);
	RET_COLTOT     VARCHAR2(2000);
	
	
	
	
	WS_TMP_CHECK   VARCHAR2(300);
	WS_IDCOL	   VARCHAR2(120);
	WS_ALINHAMENTO VARCHAR2(80);
	WS_NM_VAR_AL   VARCHAR2(400);
	WS_TEXTO_AL    VARCHAR2(4000);
	WS_PIVOT_C     VARCHAR2(4000);
	WS_CD_COLUNA   VARCHAR2(400);
	WS_PIVOT       VARCHAR2(300);
	WS_CALCULADA   VARCHAR2(800);
    WS_CALCULADA_M VARCHAR2(200);
	WS_CONTEUDO_A  VARCHAR2(4000);
	WS_CONTENT	   VARCHAR2(3000);
	WS_AGRUPADOR   VARCHAR2(4000);
	WS_BLINK_LINHA VARCHAR2(4000)  := 'N/A';
	ws_blink_aux   VARCHAR2(4000)  := 'N/A';
	WS_REPEAT      VARCHAR2(60)    := 'show';
	WS_LARGURA     VARCHAR2(60)    := '0';
	WS_NULL        VARCHAR2(1)     := NULL;
	WS_SAIDA       VARCHAR2(10)    := 'S';
	WS_POSICAO	   VARCHAR2(2000)  := ' ';
	WS_OBS         VARCHAR2(2000);
	ws_formato_excel   varchar2(20);

	WS_FIRSTID	   CHAR(1);
	WS_PIPE		   CHAR(1);

    DAT_COLUNA     DATE;
	WS_TEMPO       DATE;

	WS_QUERY_MONTADA	DBMS_SQL.VARCHAR2A;
	

	WS_NCOLUMNS			DBMS_SQL.VARCHAR2_TABLE;
	WS_PVCOLUMNS		DBMS_SQL.VARCHAR2_TABLE;
	WS_MFILTRO			DBMS_SQL.VARCHAR2_TABLE;
	WS_VCOL				DBMS_SQL.VARCHAR2_TABLE;
	WS_VCON				DBMS_SQL.VARCHAR2_TABLE;
	WS_COLUNA_ANT		DBMS_SQL.VARCHAR2_TABLE;
	WS_ARRAY_ANTERIOR   DBMS_SQL.VARCHAR2_TABLE;
	WS_ARRAY_ATUAL      DBMS_SQL.VARCHAR2_TABLE;
	WS_CLASS_ATUAL      DBMS_SQL.VARCHAR2_TABLE;

	REC_TAB             DBMS_SQL.DESC_TAB;

	WS_QUERYOC	   CLOB;
	WS_SQL         CLOB;
	WS_SQL_PIVOT   CLOB;
	WS_QUERY_PIVOT CLOB;
	WS_EXCEL       CLOB;
	WS_TITLE 	   CLOB;
	WS_CONTENT_ANT CLOB;
	RET_COLUP	   CLOB;
	WS_XATALHO	   CLOB;
	WS_ATALHO	   CLOB;
	WS_TEXTOT	   CLOB;

    WS_COUNT       NUMBER;
	WS_COUNTOR     NUMBER;
	
	WS_FIXED       NUMBER;
	WS_ROW         NUMBER;
	WS_LQUERY	   NUMBER;
	WS_STEP        NUMBER;
	WS_COUNT_V     NUMBER;
	WS_COL_VALOR   NUMBER;
	WS_AGRUP_MAX   NUMBER;
	WS_CONTENT_SUM NUMBER;
	WS_TEMP_VALOR  NUMBER := 0;
	WS_TEMP_VALOR2 NUMBER := 0;
	WS_TOTAL_LINHA NUMBER := 0;
	WS_AC_LINHA    NUMBER := 0;
	WS_LINHA_COL   NUMBER := 0;
	WS_LINHA       NUMBER := 0;
	WS_AMOSTRA     NUMBER := 0;
	WS_CHCOR	   NUMBER := 0;
	WS_CTNULL	   NUMBER := 0;
	WS_CTCOL	   NUMBER := 0;
	WS_CT_TOP      NUMBER := 0;
	WS_XCOLUNA	   NUMBER := 0;
	WS_STEPPER     NUMBER := 0;
	WS_DISTINCTMED NUMBER := 0;
	DIMENSAO_SOMA  NUMBER := 0;
	ws_inv_count   number := 0;
	WS_CSPAN	   NUMBER := 0;
	WS_TEMPO_AVG   NUMBER := 0;
	WS_TEMPO_QUERY NUMBER := 0;
	WS_COUNTER	   NUMBER := 1;
	WS_SCOL		   NUMBER := 0;
	WS_TOP         NUMBER := 0;
	WS_CCOLUNA	   NUMBER := 1;
	WS_COUNTERID   NUMBER := 0;
	WS_BINDN	   NUMBER := 0;
	WS_XCOUNT	   NUMBER := 0;
	WS_INV_TAG     NUMBER := 0;
	WS_CHILD       NUMBER := 0;
	ws_qt_cab_agru number := 0;

	WS_ARR         ARR;
	WS_PROP_NOTUP         VARCHAR2(40) := 'N';
	WS_PROP_NOTOT         VARCHAR2(40);
	WS_PROP_QUBE          VARCHAR2(40);
	WS_PROP_QUERY_STAT    VARCHAR2(40);
	WS_PROP_SOTOT         VARCHAR2(40);

	WS_PADRAO VARCHAR2(80) := 'PORTUGUESE';

	WS_ADMIN_DRILL_EX  BOOLEAN;
	WS_ADMIN_DRILL_AD  BOOLEAN;
	WS_ADMIN_FILTRO_EX BOOLEAN;
	WS_ADMIN_FILTRO_AD BOOLEAN;

	WS_SHOW_DESTAQUE   VARCHAR2(32000);
	WS_SHOW_FILTROS    VARCHAR2(32000);
	WS_ESTILO_LINHA    CLOB;--VARCHAR2(32000);

	
	WS_COLSPAN     NUMBER;
	WS_NEGRITO     VARCHAR2(40);
	
	WS_CURSOR	   INTEGER;
	WS_LINHAS	   INTEGER;
	WS_PCURSOR	   NUMBER;

	WS_COL_ARR       ARR;
	WS_COL_ARR_COUNT NUMBER := 1;

	WS_VAZIO	   BOOLEAN := TRUE;

	WS_NODATA      EXCEPTION;
	WS_SEMQUERY    EXCEPTION;

	CURSOR NC_COLUNAS IS SELECT * FROM MICRO_COLUNA WHERE CD_MICRO_VISAO = PRM_VISAO;

	TYPE WS_TMCOLUNAS IS TABLE OF MICRO_COLUNA%ROWTYPE
	    INDEX BY PLS_INTEGER;

	RET_MCOL			WS_TMCOLUNAS;

	PROCEDURE NESTED_FIX ( PRM_ALINHAMENTO IN  VARCHAR2,
	                       PRM_NEGRITO     IN  VARCHAR2,
						   PRM_COLUNA      IN  NUMBER,
						   PRM_ESTILO      IN OUT VARCHAR2 ) AS

		WS_STYLE VARCHAR2(200);	
		WS_CHILD     NUMBER;
		WS_LINHA_TH  NUMBER; 
		ws_qt_th     number; 
	BEGIN

	    WS_CHILD := PRM_COLUNA+1;

		-- Se exitir PIVOT, monta a formatação das colunas do PIVOT 
		ws_qt_th := 0;
		if prm_colup is not null then 
			if prm_estilo is null then 
				for a in (select t1.* from micro_coluna t1, TABLE(FUN.VPIPE(prm_colup)) t2
						where t1.cd_micro_visao = PRM_VISAO
							and t1.cd_coluna      = t2.column_value
						) loop 

					ws_qt_th := ws_qt_th + 1 ; 
					ws_style := null;
					
					if lower(trim(a.st_alinhamento)) in ('right','left','center') then  
						ws_style := ws_style||' text-align: '||lower(trim(a.st_alinhamento))||' ;';
					end if;
					if trim(a.st_negrito) = 'S' then
						ws_style := ws_style||' font-weight: bold;';
					end if;
					if ws_style is not null then  
						if ws_qt_th = 1 then 
							prm_estilo := prm_estilo||' table#'||ws_obj||'c tr:nth-child('||ws_qt_th||') th:nth-child(+n+'||(ws_qt_cab_agru+1)||')' ;  -- 1ª linha começa com as colunas de valores
						else 
							prm_estilo := prm_estilo||' table#'||ws_obj||'c tr:nth-child('||ws_qt_th||') th ' ;                                      -- 2º linha aplica em todas as colunas
						end if; 	
						prm_estilo := prm_estilo||' { '||trim(ws_style)||' }';
					end if; 	
				end loop ; 			
			else 
				select count(*) into ws_qt_th from TABLE(FUN.VPIPE(prm_colup)); 
			end if; 
		end if; 

		-- Formatação das colunas de TD e TH referente a coluna TD 
		ws_style := null;
	    if lower(trim(prm_alinhamento)) in ('right','left','center') then
			ws_style := ws_style||' text-align: '||lower(trim(prm_alinhamento))||';';
		end if; 
		if trim(prm_negrito) = 'S' then
			ws_style := ws_style||' font-weight: bold;';
		end if;

		ws_linha_th := ws_qt_th + 1; 

		prm_estilo := prm_estilo||' table#'||ws_obj||'c tr td:nth-child('||ws_child||')'; 
		
		if prm_colup is null then -- Não tem PIVOT 
			prm_estilo := prm_estilo||', table#'||ws_obj||'c tr th:nth-child('||(ws_child - ws_qt_cab_agru)||')' ; 
		else 	
			if ws_child <= ws_qt_cab_agru then 
				prm_estilo := prm_estilo||', table#'||ws_obj||'c tr:nth-child(1) th:nth-child('||(ws_child)||')' ;	 -- colunas sem pivot (primeiras colunas)  	
			else 
				prm_estilo := prm_estilo||', table#'||ws_obj||'c tr:nth-child('||ws_linha_th||') th:nth-child('||(ws_child - ws_qt_cab_agru)||')' ;   -- colunas com pivot (colunas de valores)
			end if; 	
		end if; 	
		prm_estilo := prm_estilo||' { '||trim(ws_style)||' }';

	END NESTED_FIX;

	PROCEDURE NESTED_CALCULADA( PRM_CALCULADA   IN VARCHAR2, 
								PRM_COLUNA      IN VARCHAR2 DEFAULT NULL, 
								PRM_DIR         IN VARCHAR2 DEFAULT NULL, 
								PRM_COUNT       IN OUT NUMBER, 
								PRM_OBJETO      VARCHAR2 DEFAULT NULL, 
								PRM_FORMULA     VARCHAR2 DEFAULT NULL, 
								PRM_SCREEN      VARCHAR2 DEFAULT NULL, 
								PRM_JUMP        VARCHAR2 DEFAULT NULL,
								PRM_MASCARA     VARCHAR2 DEFAULT NULL,
								PRM_CONTENT     VARCHAR2 DEFAULT NULL,
								PRM_CONTENT_A   VARCHAR2 DEFAULT NULL,
								PRM_CALCULADA_M VARCHAR2 DEFAULT NULL ) AS

        WS_CALCULADA   VARCHAR2(800);
        WS_CALCULADA_M VARCHAR2(200);

	BEGIN

	    IF NVL(PRM_COLUNA, 'N/A') <> 'N/A' THEN
			
			IF LENGTH(PRM_CALCULADA) > 0 THEN
				FOR I IN(SELECT COLUMN_VALUE AS VALOR FROM TABLE(FUN.VPIPE((PRM_CALCULADA)))) LOOP
					IF INSTR(I.VALOR, PRM_DIR) > 0 THEN
						IF SUBSTR(I.VALOR, 0, INSTR(I.VALOR, PRM_DIR)-1) = PRM_COLUNA THEN
							HTP.P('<td></td>');
						END IF;
					END IF;
				END LOOP;
			END IF;

        ELSIF NVL(PRM_JUMP, 'N/A') <> 'N/A' THEN

			BEGIN
				IF LENGTH(PRM_CALCULADA) > 0 THEN
					FOR I IN(SELECT COLUMN_VALUE AS VALOR, ROWNUM AS LINHA FROM TABLE(FUN.VPIPE((PRM_CALCULADA)))) LOOP
						IF INSTR(I.VALOR, PRM_DIR) > 0 THEN
							IF SUBSTR(I.VALOR, 0, INSTR(I.VALOR, PRM_DIR)-1) = PRM_COLUNA THEN
								WS_CALCULADA := FUN.XEXEC('EXEC='||SUBSTR(I.VALOR, INSTR(I.VALOR, PRM_DIR)+1), PRM_SCREEN, PRM_CONTENT, PRM_CONTENT_A);
								SELECT NVL(MASCARA, TRIM(PRM_MASCARA)) INTO WS_CALCULADA_M FROM(SELECT COLUMN_VALUE AS MASCARA, ROWNUM AS LINHA FROM TABLE(FUN.VPIPE((PRM_CALCULADA_M)))) WHERE LINHA = I.LINHA;
								HTP.P('<td '||PRM_JUMP||'>'||FUN.IFMASCARA(WS_CALCULADA, WS_CALCULADA_M, PRM_VISAO, PRM_COLUNA, PRM_OBJETO, '', PRM_FORMULA, PRM_SCREEN, WS_USUARIO)||'</td>');
							END IF;
						END IF;
					END LOOP;
				END IF;
			EXCEPTION WHEN OTHERS THEN
				HTP.P('<td '||PRM_JUMP||' data-err="'||SQLERRM||'">err</td>');
			END;
			
		ELSE

		    IF LENGTH(PRM_CALCULADA) > 0 THEN
				FOR I IN(SELECT COLUMN_VALUE AS VALOR, ROWNUM AS LINHA FROM TABLE(FUN.VPIPE((PRM_CALCULADA)))) LOOP
					IF INSTR(I.VALOR, '>') > 0 THEN
						PRM_COUNT := PRM_COUNT+1;
					END IF;
					IF INSTR(I.VALOR, '<') > 0 THEN
						PRM_COUNT := PRM_COUNT+1;
					END IF;
				END LOOP;
			END IF;

		END IF;

	END NESTED_CALCULADA;

	PROCEDURE NESTED_TD ( PRM_HINT    VARCHAR2 DEFAULT NULL,
	                      PRM_FIX     VARCHAR2 DEFAULT NULL,
						  PRM_COUNTER VARCHAR2 DEFAULT NULL,
						  PRM_IDCOL   VARCHAR2 DEFAULT NULL,
						  PRM_OBJETO  VARCHAR2 DEFAULT NULL,
						  PRM_COLUNA  VARCHAR2 DEFAULT NULL,
						  PRM_CONTENT IN OUT VARCHAR2,
						  PRM_SCREEN  VARCHAR2 DEFAULT NULL,
						  PRM_FORMULA VARCHAR2 DEFAULT NULL,
						  PRM_VISAO   VARCHAR2 DEFAULT NULL,
						  PRM_MASCARA VARCHAR2 DEFAULT NULL,
						  PRM_JUMP    VARCHAR2 DEFAULT NULL,
						  PRM_AGRUPADOR VARCHAR2 DEFAULT NULL,
						  PRM_UM        VARCHAR2 DEFAULT NULL
					    ) AS

	    WS_CONTEUDO VARCHAR2(4000);
		WS_ID       VARCHAR2(80) := '';
		WS_ATRIBUTO VARCHAR2(4000);

	BEGIN

        WS_CONTEUDO := SUBSTR(TRIM(PRM_CONTENT),1,4000); 
		WS_ID := PRM_IDCOL;

		IF NVL(PRM_MASCARA, 'N/A') <> 'N/A' THEN
			WS_CONTEUDO := FUN.IFMASCARA(WS_CONTEUDO, TRIM(PRM_MASCARA), PRM_VISAO, PRM_COLUNA, PRM_OBJETO, '', PRM_FORMULA, PRM_SCREEN, WS_USUARIO);
		END IF;

		IF NVL(PRM_UM, 'N/A') <> 'N/A' THEN
			WS_CONTEUDO := FUN.UM(PRM_COLUNA, PRM_VISAO, WS_CONTEUDO);
		END IF;

		-- Retirado a regra que inibia o 0/null da ret_sinal 01/10/21
		if prm_agrupador <> 'SEM'/* and nvl(prm_content, '0') <> '0'*/ then
			
			ws_conteudo := ws_conteudo||fun.ret_sinal(prm_objeto, prm_coluna, prm_content);
		
		end if;

		-- Aplica destaque NORMAL na celula  
		ws_blink_aux := '';
		if ret_colgrp = 0 then      -- linha normal 
			ws_blink_aux := fun.check_blink(prm_objeto, prm_coluna, prm_content, '', prm_screen, ws_usuario);
		else
            ws_blink_aux := fun.check_blink_total(prm_objeto, prm_coluna, NVL(prm_content,'0'), '', prm_screen);				
		end if;
	
        WS_ATRIBUTO := TRIM(PRM_HINT||PRM_FIX||WS_ID||ws_blink_aux||' '||PRM_JUMP);

		IF NVL(WS_ATRIBUTO, 'N/A') <> 'N/A' THEN
		    HTP.PRN('<td '||WS_ATRIBUTO||'>'||WS_CONTEUDO||'</td>');
		ELSE
			HTP.PRN('<td>'||WS_CONTEUDO||'</td>');
		END IF;

	EXCEPTION WHEN OTHERS THEN
	    HTP.PRN('<td>'||SQLERRM||'</td>');
	END NESTED_TD;

BEGIN
	
	select sysdate into ws_tempo from dual;
    
	WS_ARR := FUN.GETPROPS(PRM_OBJETO, 'CONSULTA', 'AGRUPADORES|ALTURA|AMOSTRA|BORDA_COR|CALCULADA|CALCULADA_M|CALCULADA_N|COLUNA_FINAL|COLUNA_INICIAL|DASH_MARGIN_BOT|DASH_MARGIN_LEFT|DASH_MARGIN_RIGHT|DASH_MARGIN_TOP|DEGRADE|DRILLT|FILTRO|FIXAR_TOT|FIXED-N|FONTE_CABECALHO|FONTE_CLARO|FONTE_ESCURO|FONTE_TOTAL|FONT_FAMILY|FONT_SIZE|FULL|FUNDO_CABECALHO|FUNDO_CLARO|FUNDO_ESCURO|FUNDO_TOTAL|FUNDO_VALOR|GRID_COLOR|HEAD_BOLD|LARGURA|LINHA_ACUMULADA|NAO_REPETIR|NOME_COLUNA|NOME_PIVOT|NO_OPTION|NO_RADIUS|NO_TUP|OMITIR_TOT|QUBE|QUERY_STAT|SO_TOT|SUBQUERY|TOP|TOTAL_ACUMULADO|TOTAL_GERAL_TEXTO|TOTAL_SEPARADO|TOTAL_SEPARADO_TEXTO|TOT_BOLD|TP_GRUPO|VISIVEL|XML', 'DWU');
    
    WS_ADMIN_DRILL_EX  := FUN.CHECK_ADMIN('DRILLS_EX');
	WS_ADMIN_DRILL_AD  := FUN.CHECK_ADMIN('DRILLS_ADD'); 
	WS_ADMIN_FILTRO_EX := FUN.CHECK_ADMIN('FILTERS_EX');
	WS_ADMIN_FILTRO_AD := FUN.CHECK_ADMIN('FILTERS_ADD');

	WS_PADRAO := GBL.GETLANG;
    WS_SAIDA := WS_ARR(54);

	ws_formato_excel := fun.ret_var('FORMATO_EXCEL', ws_usuario); 
	if nvl(ws_formato_excel,'N/A') = 'N/A' then 
 		ws_formato_excel := fun.ret_var('FORMATO_EXCEL', 'DWU'); 
	end if; 


	IF PRM_DRILL = 'C' THEN
        WS_PROP_NOTUP := 'N';
	END IF;

    IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
		FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '<?xml version="1.0" encoding="UTF-8"?><?mso-application progid="Excel.Sheet"?>');
		FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40" xmlns:x2="http://schemas.microsoft.com/office/excel/2003/xml">');
		FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '<Worksheet ss:Name="Plan1"><Table>', '', '');
    END IF; 

	IF PRM_DASHBOARD <> 'false' THEN
	    WS_PROPAGATION := PRM_PROPAGATION;
	END IF;

	SELECT COLUMN_VALUE INTO WS_SUBQUERY FROM TABLE(FUN.VPIPE((WS_ARR(45)))) WHERE ROWNUM = 1;

    WS_ISOLADO := WS_ARR(16);

	IF(INSTR(PRM_POSX, '-') = 1) THEN
		WS_POSIX := '5px';
	ELSE
		WS_POSIX := PRM_POSX;
	END IF;

	IF(INSTR(PRM_POSY, '-') = 1) THEN
		WS_POSIY := '65px';
	ELSE
		WS_POSIY := NVL(PRM_POSY, 0);
	END IF;

	IF PRM_DRILL = 'C' THEN
        WS_COD := PRM_OBJETO;
	ELSE
	    SELECT COD INTO WS_COD FROM OBJETOS WHERE CD_OBJETO = PRM_OBJETO;
	END IF;

	IF PRM_DASHBOARD <> 'false' THEN
	    WS_ORDER := 'order: '||WS_POSIX||';';
	ELSE
		WS_ORDER := 'left: '||WS_POSIX||';';
	END IF;

	IF NVL(PRM_POSX,'NOLOC') <> 'NOLOC' THEN
	    WS_POSICAO := 'position: absolute; top:'||WS_POSIY||'; left: 5px; '||WS_ORDER||' ';
	ELSE
	    IF(PRM_DRILL = 'O') THEN
		    WS_POSICAO := ' position: absolute; top: 8px; left: 8px; ';
		ELSE
	        WS_POSICAO := ' position: absolute; top: 110px; left: 7px; ';
		END IF;
	END IF;

	IF PRM_DRILL = 'Y' THEN
	    WS_OBJ := PRM_OBJETO||'trl';
	ELSE
	    WS_OBJ := PRM_OBJETO;
	END IF;

	if prm_dashboard <> 'N' then
	    ws_posicao := ws_posicao||' margin-top: '||ws_arr(13)||';';
		ws_posicao := ws_posicao||' margin-right: '||ws_arr(12)||';';
		ws_posicao := ws_posicao||' margin-bottom: '||ws_arr(10)||';';
		ws_posicao := ws_posicao||' margin-left: '||ws_arr(11)||';';
	end if;

	WS_COLUP     := PRM_COLUP;
	WS_COLUNA    := PRM_COLUNA;

	IF PRM_DRILL = 'C' THEN
        WS_AGRUPADOR := PRM_AGRUPADOR;
	ELSE
	    WS_AGRUPADOR := FUN.CONV_TEMPLATE(PRM_VISAO, PRM_AGRUPADOR);
	END IF;

	WS_RP	      := PRM_RP;
	WS_MODE       := 'ED';
	WS_TEXTO      := PRM_PARAMETROS;
    WS_PARAMETROS := FUN.CONVERTE(PRM_PARAMETROS);

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
	    IF TRIM(RET_MCOL(WS_COUNTER).ST_AGRUPADOR) <> 'SEM' AND FUN.SETEM(WS_AGRUPADOR, TRIM(RET_MCOL(WS_COUNTER).CD_COLUNA)) AND (TRIM(RET_MCOL(WS_COUNTER).ST_INVISIVEL) <> 'S') THEN
		    WS_SCOL := WS_SCOL + 1;
	    END IF;
	END LOOP;

	IF NVL(PRM_OBJETO,'%$%') <> '%$%' AND PRM_OBJETO <> 'newquery' AND PRM_DRILL <> 'C' THEN
	   WS_RP := WS_ARR(52);
	END IF;

	WS_SEM := 1;

	IF  SUBSTR(WS_PARAMETROS,LENGTH(WS_PARAMETROS),1)='|' THEN
        WS_PARAMETROS := SUBSTR(WS_PARAMETROS,1,LENGTH(WS_PARAMETROS)-1);
    END IF;

	WS_ORDEM := '';
	WS_COUNTOR := 0;

	SELECT COUNT(*) INTO WS_COUNTOR FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJETO AND CD_PROP = 'ORDEM' AND OWNER = WS_USUARIO AND PROPRIEDADE IS NOT NULL;
	
	IF WS_COUNTOR = 1 THEN
	    SELECT UPPER(PROPRIEDADE) INTO WS_ORDEM_QUERY FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJETO AND CD_PROP = 'ORDEM' AND OWNER = WS_USUARIO;
	    WS_ORDEM := WS_ORDEM_QUERY;
	ELSE
	    SELECT COUNT(*) INTO WS_COUNTOR FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJETO AND CD_PROP = 'ORDEM' AND OWNER = 'DWU'  AND PROPRIEDADE IS NOT NULL;
	    IF WS_COUNTOR = 1 THEN
	        SELECT UPPER(PROPRIEDADE) INTO WS_ORDEM_QUERY FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJETO AND CD_PROP = 'ORDEM' AND OWNER = 'DWU';
	    END IF;
	END IF;

	IF LENGTH(WS_SUBQUERY) > 0 THEN
	    WS_TMP_JUMP := 'seta '||WS_SUBQUERY;
	ELSE
	    WS_TMP_JUMP := 'setadown';
	END IF;

	IF LENGTH(WS_SUBQUERY) > 0 THEN
        WS_SUBQUERY := 'data-subquery="'||WS_SUBQUERY||'"';
	END IF;

	SELECT NVL(SHOW_ONLY, 'N') INTO WS_SHOW_ONLY FROM USUARIOS WHERE USU_NOME = WS_USUARIO;

	IF WS_ARR(25) <> '0' AND WS_SHOW_ONLY = 'S' THEN
	    WS_FULL := ' full';
	END IF;

	IF PRM_DRILL = 'Y' THEN
	    WS_FULL := ' drill'||WS_FULL;
	END IF;

	IF LENGTH(WS_ARR(4)) > 0 THEN
		WS_BORDA := 'border: 1px solid '||TRIM(WS_ARR(4))||';';
	END IF;

	IF PRM_DRILL <> 'Y' THEN
	    WS_HTML := 'data-swipe=""';
	END IF;

	HTP.P('<div id="'||WS_OBJ||'" onmousedown="'||WS_PROPAGATION||'" class="dragme front'||WS_FULL||'" '||WS_HTML||'>');
		
		IF  PRM_DRILL <> 'C' THEN
		    SELECT SUBTITULO, NM_OBJETO, FUN.SUBPAR(DS_OBJETO, PRM_SCREEN) INTO WS_SUBTITULO, WS_NOME, WS_OBS FROM OBJETOS WHERE CD_OBJETO = PRM_OBJETO;
		END IF;

		IF  NVL(PRM_OBJETO,'%?%')<>'%?%' THEN
			WS_TITULO := WS_NOME;
		ELSE
			WS_TITULO := '';
		END IF;

		IF WS_ARR(46) <> 'X' THEN
			WS_TOP := WS_ARR(46);
		END IF;

		IF  PRM_DRILL <> 'C' THEN
			OBJ.TITULO(PRM_OBJETO, PRM_DRILL, WS_TITULO, PRM_SCREEN, WS_USUARIO);
		ELSE
			BEGIN
				SELECT DS_FAV INTO WS_TITULO FROM BI_CUSTOM_FAV WHERE CD_CUSTOM = PRM_SELF;
				HTP.P('<h2>'||FUN.SUBPAR(WS_TITULO, PRM_SCREEN)||'</h2>');
			EXCEPTION WHEN OTHERS THEN
				HTP.P('<h2></h2>');
			END;
		END IF;
    	
		IF PRM_DRILL <> 'C' THEN
			IF PRM_DRILL = 'Y' THEN
				HTP.P('<a class="fechar" id="'||WS_OBJ||'fechar" title="'||FUN.LANG('Fechar')||'">');
					
				HTP.P('</a>');
							
				IF WS_ADMIN = 'A' THEN
					HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJ||'more">');
						HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'atrib', PRM_SCREEN));
							HTP.P('<span class="preferencias" title="'||FUN.LANG('Propriedades')||'"></span>');
							HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'filter', PRM_VISAO));
							HTP.P('<span class="sigma" title="'||FUN.LANG('Linha calculada')||'"></span>');
							HTP.P('<span class="lightbulb" title="'||FUN.LANG('Drill')||'"></span>');
							HTP.P(FUN.SHOWTAG(WS_OBJ||'c', 'excel'));
							HTP.P('<span class="data_table" title="'||FUN.LANG('Alterar Consulta')||'"></span>');
							HTP.P(FUN.SHOWTAG('', 'star'));
							HTP.P(FUN.SHOWTAG(WS_OBJ||'c', 'fav'));
					HTP.P('</span>');
				ELSE
					IF WS_ARR(38) <> 'S' THEN

						SELECT COUNT(*) INTO WS_COUNT FROM PONTO_AVALIACAO WHERE CS_AGRUPADOR IN (SELECT NVL(CD_COLUNA, 'N/A') FROM MICRO_COLUNA WHERE ST_AGRUPADOR = 'TPT' AND CD_MICRO_VISAO = PRM_VISAO) AND CD_PONTO = PRM_OBJETO;

						IF WS_COUNT > 0 THEN
							SELECT NVL(CS_AGRUPADOR, 'N/A') INTO WS_TPT FROM PONTO_AVALIACAO WHERE CS_AGRUPADOR IN (SELECT NVL(CD_COLUNA, 'N/A') FROM MICRO_COLUNA WHERE ST_AGRUPADOR = 'TPT' AND CD_MICRO_VISAO = PRM_VISAO) AND CD_PONTO = PRM_OBJETO;
						ELSE
							WS_TPT := 'N/A';
						END IF;

						IF NOT WS_ADMIN_DRILL_EX AND NOT WS_ADMIN_DRILL_AD AND NOT WS_ADMIN_FILTRO_EX AND NOT WS_ADMIN_FILTRO_AD THEN
							WS_LARGURA := 'max-width: 68px; max-height: 32px;';
						ELSIF (WS_ADMIN_DRILL_EX OR WS_ADMIN_DRILL_AD) AND (WS_ADMIN_FILTRO_EX OR WS_ADMIN_FILTRO_AD) THEN
							WS_LARGURA := 'max-width: 102px; max-height: 64px;';
						ELSE	
							WS_LARGURA := 'max-width: 68px; max-height: 64px;';
						END IF;

						HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJ||'more" style="'||WS_LARGURA||'">');

							IF WS_ADMIN_DRILL_EX OR WS_ADMIN_DRILL_AD THEN
								HTP.P('<span class="lightbulb" title="'||FUN.LANG('Drill')||'"></span>');
							END IF;

							IF WS_ADMIN_FILTRO_EX OR WS_ADMIN_FILTRO_AD THEN
								HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'filter', PRM_VISAO));
							END IF;

							HTP.P(FUN.SHOWTAG(WS_OBJ||'c', 'excel'));

							IF WS_TPT <> 'N/A' THEN
								HTP.P('<span class="data_table" title="'||FUN.LANG('Alterar Template')||'" onclick=" fakeOption('''||WS_TPT||''', ''Op&ccedil;&otilde;es do template'', ''template'', '''||PRM_VISAO||''');"></span>');
							END IF;
							HTP.P(FUN.SHOWTAG(WS_OBJ||'c', 'fav'));

						HTP.P('</span>');

					END IF;
				END IF;
			ELSIF PRM_DRILL = 'O' THEN
				HTP.P(WS_NULL);
			ELSE
				IF WS_ADMIN = 'A' THEN
					HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJ||'more">');
						HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'atrib', PRM_SCREEN));
						HTP.P('<span class="preferencias" data-visao="'||PRM_VISAO||'" data-drill="'||PRM_DRILL||'" title="'||FUN.LANG('Propriedades')||'"></span>');
						HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'filter', PRM_VISAO));
						HTP.P('<span class="sigma" title="'||FUN.LANG('Linha calculada')||'"></span>');
						HTP.P('<span class="lightbulb" title="Drill"></span>');
						HTP.P(FUN.SHOWTAG(WS_OBJ||'c', 'excel'));
						HTP.P('<span class="data_table" title="'||FUN.LANG('Alterar Consulta')||'"></span>');
						HTP.P(FUN.SHOWTAG('', 'star'));
						FCL.BUTTON_LIXO('dl_obj', PRM_OBJETO=> PRM_OBJETO, PRM_TAG => 'span');
					HTP.P('</span>');
				ELSE
					IF WS_ARR(38) <> 'S' THEN
						SELECT COUNT(*) INTO WS_COUNT FROM PONTO_AVALIACAO WHERE CS_AGRUPADOR IN (SELECT NVL(CD_COLUNA, 'N/A') FROM MICRO_COLUNA WHERE ST_AGRUPADOR = 'TPT' AND CD_MICRO_VISAO = PRM_VISAO) AND CD_PONTO = PRM_OBJETO;

						IF WS_COUNT > 0 THEN
							SELECT NVL(CS_AGRUPADOR, 'N/A') INTO WS_TPT FROM PONTO_AVALIACAO WHERE CS_AGRUPADOR IN (SELECT NVL(CD_COLUNA, 'N/A') FROM MICRO_COLUNA WHERE ST_AGRUPADOR = 'TPT' AND CD_MICRO_VISAO = PRM_VISAO) AND CD_PONTO = PRM_OBJETO;
						ELSE
							WS_TPT := 'N/A';
						END IF;

						IF NOT WS_ADMIN_DRILL_EX AND NOT WS_ADMIN_DRILL_AD AND NOT WS_ADMIN_FILTRO_EX AND NOT WS_ADMIN_FILTRO_AD THEN
							IF WS_TPT = 'N/A'THEN
								WS_LARGURA := 'max-width: 34px; max-height: 32px;';
							ELSE
								WS_LARGURA := 'max-width: 68px; max-height: 32px;';
							END IF;
						ELSIF (WS_ADMIN_DRILL_EX OR WS_ADMIN_DRILL_AD) AND (WS_ADMIN_FILTRO_EX OR WS_ADMIN_FILTRO_AD) THEN
							IF WS_TPT <> 'N/A'THEN
								WS_LARGURA := 'max-width: 102px; max-height: 64px;';
							ELSE
								WS_LARGURA := 'max-width: 102px; max-height: 32px;';
							END IF;
						ELSE
							IF WS_TPT <> 'N/A'THEN
								WS_LARGURA := 'max-width: 102px; max-height: 32px;';
							ELSE
								WS_LARGURA := 'max-width: 68px; max-height: 32px;';
							END IF;
						END IF;

						HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJ||'more" style="'||WS_LARGURA||'">');

						WS_LARGURA := '';

							IF WS_ADMIN_DRILL_EX OR WS_ADMIN_DRILL_AD THEN
								HTP.P('<span class="lightbulb" title="'||FUN.LANG('Drill')||'"></span>');
							END IF;

							IF WS_ADMIN_FILTRO_EX OR WS_ADMIN_FILTRO_AD THEN
								HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'filter', PRM_VISAO));
							END IF;

							HTP.P(FUN.SHOWTAG(WS_OBJ||'c', 'excel'));
							IF WS_TPT <> 'N/A'THEN
								HTP.P('<span class="data_table" title="'||FUN.LANG('Alterar Template')||'" onclick=" fakeOption('''||WS_TPT||''', ''Op&ccedil;&otilde;es do template'', ''template'', '''||PRM_VISAO||''');"></span>');
							END IF;

						HTP.P('</span>');

					END IF;
				END IF;
			END IF;


			HTP.P('<form name="busca" style="display: none;">');
				HTP.P('<input type="hidden" name="show_'||WS_OBJ||'" id="show_'||WS_OBJ||'" value="prm_drill='||PRM_DRILL||'&prm_objeto='||PRM_OBJETO||'&PRM_POSX='||WS_POSIX||'&PRM_ZINDEX='||PRM_ZINDEX||'&PRM_POSY='||WS_POSIY||'&prm_parametros='||WS_PARAMETROS||'&prm_screen='||PRM_SCREEN||'&prm_track=&prm_objeton=" />');
				HTP.P('<input type="hidden" name="npar_'||WS_OBJ||'" id="par_'||WS_OBJ||'" value="'||WS_PARAMETROS||'" />');
				HTP.P('<input type="hidden" name="nord_'||WS_OBJ||'" id="ord_'||WS_OBJ||'" value="'||WS_ORDEM||'" />');
				HTP.P('<input type="hidden" name="nmvs_'||WS_OBJ||'" id="mvs_'||WS_OBJ||'" value="'||PRM_VISAO||'" />');
				HTP.P('<input type="hidden" name="ncol_'||WS_OBJ||'" id="col_'||WS_OBJ||'" value="'||WS_COLUNA||'" />');
				HTP.P('<input type="hidden" name="nagp_'||WS_OBJ||'" id="agp_'||WS_OBJ||'" value="'||WS_AGRUPADOR||'" />');
				HTP.P('<input type="hidden" name="nrps_'||WS_OBJ||'" id="rps_'||WS_OBJ||'" value="'||WS_RP||'" />');
				HTP.P('<input type="hidden" name="ndri_'||WS_OBJ||'" id="dri_'||WS_OBJ||'" value="'||WS_DRILL||'" />');
				HTP.P('<input type="hidden" name="ncup_'||WS_OBJ||'" id="cup_'||WS_OBJ||'" value="'||WS_COLUP||'" />');
				HTP.P('<input type="hidden" name="nsco_'||WS_OBJ||'" id="sco_'||WS_OBJ||'" value="" />' );
				htp.p('<input type="hidden" id="excel_mask_'||ws_obj||'" value="'||fun.getprop(prm_objeto, 'EXCEL_MASK')||'" />' );
					
			HTP.P('</form>');

		ELSE 
			
			HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed hover" id="'||WS_OBJ||'more">');
				HTP.P('<span class="conf" title="'||FUN.LANG('Propriedades')||'"></span>');
				HTP.P(FUN.SHOWTAG(WS_OBJ||'c', 'excel'));
				IF PRM_SELF <> 0 THEN
					FCL.BUTTON_LIXO('deletaCustom', 'prm_custom', PRM_SELF, PRM_TAG => 'span');
				ELSE
					HTP.P('<span class="clear" title="Limpar" onclick="eraseCustom()">');
						HTP.P('<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"width="360px" height="360px" viewBox="0 0 360 360" style="enable-background:new 0 0 360 360;" xml:space="preserve"> <g> <g> <path d="M348.994,102.946L250.04,3.993c-5.323-5.323-13.954-5.324-19.277,0l-153.7,153.701l118.23,118.23l153.701-153.7 C354.317,116.902,354.317,108.271,348.994,102.946z"/> <path d="M52.646,182.11l-41.64,41.64c-5.324,5.322-5.324,13.953,0,19.275l98.954,98.957c5.323,5.322,13.954,5.32,19.277,0 l41.639-41.641L52.646,182.11z"/> <polygon points="150.133,360 341.767,360 341.767,331.949 182.806,331.949 		"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
					HTP.P('</span>');
				END IF;
				HTP.PRN('<input type="hidden" id="par_'||WS_OBJ||'" value="prm_visao='||PRM_VISAO||'&prm_coluna_agrup='||WS_COLUNA||'&prm_coluna_valor='||WS_AGRUPADOR||'&prm_coluna_pivot='||WS_COLUP||'&prm_coluna_tipo='||WS_RP||'&prm_limite=&filtropipe='||PRM_PARAMETROS||'" />');

			HTP.P('</span>');

			HTP.P('<div id="custom-conteudo-new" class="optionbox">');
				
				HTP.P('<label for="custom-conteudo-desc">NOME</label>');
				HTP.P('<input placeholder="DESCRI&Ccedil;&Atilde;O" maxlength="80" value="" data-event="false" id="custom-conteudo-desc" />');
				HTP.P('<label for="custom-conteudo-group">GRUPO</label>');
				HTP.P('<input placeholder="GRUPO" maxlength="40" value="" data-event="false" list="group-list" id="custom-conteudo-group" />');
				
				HTP.P('<datalist id="group-list">');
					FOR I IN(SELECT DISTINCT GRUPO FROM BI_CUSTOM_FAV) LOOP
						HTP.P('<option value="'||I.GRUPO||'">');
					END LOOP;
				HTP.P('</datalist>');
			HTP.P('</div>');

			WS_NOME := PRM_OBJETO;

		END IF;
		
		WS_HTML := '';
		
		IF WS_ARR(39) <> 'N' THEN
        	WS_HTML := 'div#'||WS_OBJ||', span#'||WS_OBJ||'_ds { border-radius: 0; } div#'||WS_OBJ||' /*span#'||WS_OBJ||'more { border-radius: 0 0 6px 0; }*/';
		END IF;

		HTP.P('<style>div#'||WS_OBJ||' { background-color: '||WS_ARR(30)||'; '||WS_POSICAO||' max-width: calc(100% - '||WS_ARR(11)||' - '||WS_ARR(12)||'); '||WS_BORDA||' }</style>');
		HTP.P('<style>div#'||WS_OBJ||' table tr td, div#'||WS_OBJ||' table tr th { font-size: '||WS_ARR(24)||'; font-family: '||WS_ARR(23)||'; } '||WS_HTML||'</style>');

		WS_HTML := '';

		IF WS_ARR(44) = 'S' OR WS_ARR(41) = 'S' THEN
			HTP.P('<style>');
				IF WS_ARR(44) = 'S' THEN
					HTP.P('div#'||WS_OBJ||' tr.total.normal { display: none; }');
				END IF;
				IF WS_ARR(41) = 'S' THEN
					HTP.P('div#'||WS_OBJ||' tr.total.geral { display: none; }');
				END IF;
			HTP.P('</style>');
		END IF;

		WS_SHOW_FILTROS  := FUN.SHOW_FILTROS(TRIM(WS_PARAMETROS), WS_CURSOR, WS_ISOLADO, PRM_OBJETO, PRM_VISAO, PRM_SCREEN);
		WS_SHOW_DESTAQUE := FUN.SHOW_DESTAQUES(TRIM(WS_PARAMETROS), WS_CURSOR, WS_ISOLADO, PRM_OBJETO, PRM_VISAO, PRM_SCREEN);

		IF LENGTH(TRIM(WS_SHOW_FILTROS)) > 3 OR LENGTH(TRIM(WS_SHOW_DESTAQUE)) > 3 OR LENGTH(TRIM(WS_OBS)) > 3 THEN
		
			HTP.P('<span class="turn">');

				IF NVL(WS_OBS, 'N/A') <> 'N/A' THEN
					HTP.P('<span class="obs" data-obs="<h4>Observa&ccedil;&otilde;es do objeto</h4><span>'||WS_OBS||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">&#63;</span>');
				END IF;

				WS_SHOW_FILTROS  := FUN.SHOW_FILTROS(TRIM(WS_PARAMETROS), WS_CURSOR, WS_ISOLADO, PRM_OBJETO, PRM_VISAO, PRM_SCREEN);
				WS_SHOW_DESTAQUE := FUN.SHOW_DESTAQUES(TRIM(WS_PARAMETROS), WS_CURSOR, WS_ISOLADO, PRM_OBJETO, PRM_VISAO, PRM_SCREEN);

				IF TO_NUMBER(FUN.RET_VAR('ORACLE_VERSION')) > 10 THEN
					SELECT COUNT(*) INTO WS_COUNTER FROM TABLE(FUN.VPIPE_PAR(PRM_COLUNA));
					IF WS_COUNTER = 0 AND NVL(TRIM(PRM_COLUP), 'null') = 'null' THEN

						HTP.P('<span class="arrowturn">&#x21B2;</span>');
						IF LENGTH(TRIM(WS_SHOW_FILTROS)) > 3 THEN
							HTP.P('<span class="filtros">F</span>');
						END IF;

					END IF;
				END IF;

				IF LENGTH(TRIM(WS_SHOW_FILTROS)) > 3 THEN
					IF WS_COUNTER <> 0 OR NVL(TRIM(PRM_COLUP), 'null') <> 'null' THEN
						HTP.P('<span class="filtros">F</span>');
					END IF;
				END IF;

				IF LENGTH(TRIM(WS_SHOW_DESTAQUE)) > 3 THEN
					HTP.P('<span class="destaques">');
						
					HTP.P('</span>');
				END IF;

			HTP.P('</span>');
		END IF;

		HTP.PRN('<ul id="'||WS_OBJ||'-filterlist" style="display: none;" >');
			HTP.PRN(WS_SHOW_FILTROS);
		HTP.PRN('</ul>');
		
		HTP.PRN('<ul id="'||WS_OBJ||'-destaquelist" style="display: none;" >');
			HTP.PRN(WS_SHOW_DESTAQUE);
		HTP.PRN('</ul>');

		HTP.P('<div id="dados_'||WS_OBJ||'" data-formato_excel="'||ws_formato_excel||'" data-left="'||WS_POSIX||'" data-top="'||WS_POSIY||'" data-drill="'||PRM_DRILL||'" data-grupo="'||WS_ARR(52)||'" data-full="'||WS_ARR(25)||'" data-visao="'||PRM_VISAO||'" data-track="'||PRM_TRACK||'"></div>');

		BEGIN
			WS_SQL := CORE.MONTA_QUERY_DIRECT(PRM_VISAO, WS_COLUNA, WS_PARAMETROS, WS_RP, WS_COLUP, WS_QUERY_PIVOT, WS_QUERY_MONTADA, WS_LQUERY, WS_NCOLUMNS, WS_PVCOLUMNS, WS_AGRUPADOR, WS_MFILTRO, PRM_OBJETO, WS_ORDEM_QUERY, PRM_SCREEN => PRM_SCREEN, PRM_CROSS => 'N', PRM_CAB_CROSS => WS_CAB_CROSS, PRM_SELF => PRM_SELF);
			
			IF WS_SHOW_ONLY <> 'S' THEN
				INSERT INTO LOG_EVENTOS VALUES (SYSDATE, substr(PRM_VISAO||'/'||WS_COLUNA||'/'||TRIM(WS_PARAMETROS)||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR,1,2000), WS_USUARIO, 'ALL', 'no_user', '01');
				COMMIT;
			END IF;

		EXCEPTION WHEN OTHERS THEN 
			RAISE WS_SEMQUERY;
		END;
		
		IF WS_SQL = 'Sem Query' THEN
		    RAISE WS_SEMQUERY;
		END IF;

		IF WS_SQL = 'Sem Dados' THEN
		    RAISE WS_NODATA;
		END IF;

		BEGIN
			WS_QUERYOC := '';
			WS_COUNTER := 0;
			
			LOOP
				WS_COUNTER := WS_COUNTER + 1;
				IF  WS_COUNTER > WS_QUERY_MONTADA.COUNT THEN
					EXIT;
				END IF;
				WS_QUERYOC := WS_QUERYOC||WS_QUERY_MONTADA(WS_COUNTER);
				
			END LOOP;
		END;

		WS_TITLE := REPLACE(PRM_PARAMETROS, ('   '), (' '))||WS_QUERYOC;

		WS_SQL_PIVOT := WS_QUERY_PIVOT;
		
		WS_HTML := ''; 

	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > WS_QUERY_MONTADA.COUNT THEN
	    	EXIT;
	    END IF;
		
	    WS_QUERYOC := WS_QUERYOC||WS_QUERY_MONTADA(WS_COUNTER);

	    IF WS_ARR(42) = 'S' THEN
			IF INSTR(WS_OBJ, 'trl') = 0 THEN
				IF INSTR(WS_QUERY_MONTADA(WS_COUNTER), 'SEG') > 0 AND WS_ADMIN = 'A' THEN
					HTP.P('<span style="z-index: 2; height: 15px; width: 16px; position: absolute; top: 7px; right: 7px; opacity: 0.3;">');
						HTP.P('<svg height="512pt" viewBox="-34 0 512 512" width="512pt" xmlns="http://www.w3.org/2000/svg" style="width: inherit;height: inherit;"><path d="m221.703125 0-221.703125 128v256l221.703125 128 221.703125-128v-256zm176.515625 136.652344-176.515625 101.914062-176.515625-101.914062 176.515625-101.910156zm-368.132812 26.027344 176.574218 101.941406v203.953125l-176.574218-101.945313zm206.660156 305.894531v-203.953125l176.574218-101.941406v203.949218zm0 0"></path></svg>');
					HTP.P('</span>');
				END IF;
			END IF;
		END IF;
	END LOOP;

	WS_COUNTER := 0;
	
	/*HTP.P(TO_CHAR(SYSDATE,'DD/MM/YYYYY HH:MI:SS'));
	HTP.P(TO_CHAR(WS_TEMPO,'DD/MM/YYYYY HH:MI:SS'));
	HTP.P(((sysdate-ws_tempo)*1440)*60*1000);*/

	--((sysdate-ws_tempo)*1440)*60*1000) regra milesegundos.
	--0.0006944444444444444 1 min
	--0.00023148148148148146 20 seg

	IF WS_ARR(43) = 'S' OR (SYSDATE > WS_TEMPO+(0.00023148148148148146)) THEN
        
		INSERT INTO QUERY_STAT
					(ID_STAT,DT_STAT,CD_OBJETO,NM_MICRO_VISAO,NM_TABELA,CS_COLUNA,CS_COLUP,CS_AGRUPADOR,CS_UTILIZADOS,NM_FAST_CUBE,TEMPO)
			 VALUES			   
			 		(WS_USUARIO, SYSDATE, PRM_OBJETO,prm_visao, '', SUBSTR(WS_PARAMETROS, 1 ,INSTR(WS_PARAMETROS,'|')-1), '', '', '', '', ((sysdate-ws_tempo)*1440)*60*1000);
		
		BEGIN
		
			SELECT DISTINCT FIRST_VALUE(TEMPO) OVER (ORDER BY DT_STAT DESC) INTO WS_TEMPO_QUERY FROM QUERY_STAT WHERE TRIM(CD_OBJETO) = TRIM(PRM_OBJETO);
	
			IF NVL(WS_TEMPO_QUERY, 999) <> 999 THEN
				SELECT ROUND(AVG(TEMPO)) INTO WS_TEMPO_AVG FROM QUERY_STAT WHERE CD_OBJETO = PRM_OBJETO AND TO_CHAR(DT_STAT, 'DD/MM/YY') = TO_CHAR(SYSDATE, 'DD/MM/YY');
				WS_QUERY_HINT := 'Tempo da &uacute;ltima recarga: '||WS_TEMPO_QUERY||'ms &#10;Tempo m&eacute;dio de hoje: '||WS_TEMPO_AVG||'ms';
			END IF;

		EXCEPTION WHEN OTHERS THEN
			WS_QUERY_HINT := '';
		END;

		
	END IF;

		IF INSTR(PRM_OBJETO, 'trl') = 0 and prm_drill <>'Y' THEN
			HTP.P('<span id="'||PRM_OBJETO||'sync" class="sync" title="'||WS_QUERY_HINT||'"><img src="dwu.fcl.download?arquivo=sinchronize.png" /></span>');
		END IF;


    BEGIN

		WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
		DBMS_SQL.PARSE( C => WS_CURSOR, STATEMENT => WS_QUERY_MONTADA, LB => 1, UB => WS_LQUERY, LFFLG => TRUE, LANGUAGE_FLAG => DBMS_SQL.NATIVE );
		WS_BINDS := CORE.BIND_DIRECT(WS_PARAMETROS, WS_CURSOR, '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN);
		WS_BINDS := REPLACE(WS_BINDS, 'Binds Carregadas=|', '');

		WS_COUNTER := 0;

		LOOP
			WS_COUNTER := WS_COUNTER + 1;
			IF  WS_COUNTER > WS_NCOLUMNS.COUNT-1 THEN
				EXIT;
			END IF;
			
			BEGIN
				DBMS_SQL.DESCRIBE_COLUMNS(WS_CURSOR, WS_COUNTER, REC_TAB);

				IF REC_TAB(WS_COUNTER).COL_TYPE = 12 AND RET_MCOL(WS_CCOLUNA).NM_MASCARA = 'SEM' THEN
					DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, DAT_COLUNA);
				ELSE
					DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, RET_COLUNA, 3000);
				END IF;
			EXCEPTION 
			    WHEN OTHERS THEN
				    DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, RET_COLUNA, 3000);
			END;

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
    
	END;

	IF WS_ADMIN = 'A' THEN
		IF PRM_DRILL <> 'O' THEN
			HTP.P('<textarea readonly class="faketitle" id="'||WS_OBJ||'faketitle" ontouch="document.getElementById('''||WS_OBJ||'faketitle'').select(); document.execCommand(''Copy'');">');
				BEGIN
					FCL.REPLACE_BINDS(WS_TITLE, WS_BINDS);			 
				EXCEPTION WHEN OTHERS THEN
					HTP.P('');
				END;
			HTP.P('</textarea>');
		END IF;
	END IF;

	BEGIN
		WS_LARGURA := WS_ARR(33);
		IF WS_LARGURA = '0' THEN
		    WS_LARGURA := '4000';
		END IF;
	EXCEPTION WHEN OTHERS THEN
	    WS_LARGURA := '4000';
	END;

	BEGIN
	    WS_CTEMP := WS_ARR(2);
		IF WS_CTEMP = '0' THEN
		    WS_CTEMP := '6000';
		END IF;
	EXCEPTION WHEN OTHERS THEN
	    WS_CTEMP := '6000';
	END;

	WS_FIXED := NVL(WS_ARR(18), '9999')+1;
	IF LENGTH(WS_ARR(48)) > 0 AND WS_FIXED > 0 THEN
		WS_FIXED := 999;
	END IF;

	IF PRM_DRILL = 'C' THEN
	    WS_SAIDA := 'C';
	END IF;

	IF WS_SAIDA <> 'O' THEN

	    HTP.P('<style>div#'||WS_OBJ||'dv2 { max-width: '||WS_LARGURA||'px; '||FCL.FPDATA(WS_CTEMP,'0','',' max-height: '||WS_CTEMP||'px;')||' cursor: default;');

		IF WS_ARR(14) = 'S' THEN
			HTP.PRN(' background: -webkit-linear-gradient('||WS_ARR(27)||', '||WS_ARR(28)||'); background: linear-gradient('||WS_ARR(27)||', '||WS_ARR(28)||');');
		END IF;

		HTP.PRN('}');

		HTP.P('table#'||WS_OBJ||'c tr.total td, div#'||WS_OBJ||'fixed li.total { background-color: '||WS_ARR(29)||' !important; color: '||WS_ARR(22)||'; }');
		
		IF  WS_ARR(14) <> 'S' THEN
			HTP.PRN('table#'||WS_OBJ||'c tr.cl { background: '||WS_ARR(27)||'; color: '||WS_ARR(20)||'; }');
			HTP.PRN('table#'||WS_OBJ||'c tr.es { background: '||WS_ARR(28)||'; color: '||WS_ARR(21)||'; }');
		ELSE
			HTP.PRN('table#'||WS_OBJ||'c tr.cl { color: '||WS_ARR(20)||'; }');
			HTP.PRN('table#'||WS_OBJ||'c tr.es { color: '||WS_ARR(21)||'; }');
		END IF;
			
		HTP.P('div#'||WS_OBJ||' table tr td, div#'||WS_OBJ||' table tr th { outline: 1px solid '||WS_ARR(31)||'; outline-offset: 0; }');
			
		HTP.PRN('td.flag, li.seta, td.seta, td.setadown { padding-left: 13px; }');
			
		IF WS_ARR(17) = 'S' THEN
			HTP.PRN('table#'||PRM_OBJETO||'trlc tbody tr.total.geral td, table#'||PRM_OBJETO||'c tbody tr.total.geral td { bottom: 1px; position: sticky; position: -webkit-sticky; }');
		END IF;

		HTP.P('div#'||WS_OBJ||'dv2 thead tr { background: '||WS_ARR(26)||'; color: '||WS_ARR(19)||'; }');

		HTP.PRN('</style>');

		HTP.PRN('<div class="fonte" data-resize="" data-maxheight="'||WS_CTEMP||'" data-maxwidth="'||WS_LARGURA||'" id="'||WS_OBJ||'dv2">');

		HTP.P('<div id="'||WS_OBJ||'m">');

		
		HTP.P('<table id="'||WS_OBJ||'c">');

	END IF;

	WS_COUNTER     := 0;
	WS_COUNTERID   := 1;
	WS_CCOLUNA     := 0;
    WS_STEP        := 0;
	ws_qt_cab_agru := 0; 

	IF WS_SAIDA <> 'O' THEN
	    IF WS_ARR(32) = 'bold' THEN
            WS_JUMP := 'bld';
		END IF;
		HTP.P('<thead class="'||WS_JUMP||'">');
	END IF;

    IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
	    FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '<Row>', '', '');
    END IF;

	IF WS_SAIDA <> 'O' THEN
		HTP.P('<tr>');
	END IF;

	WS_ROW := WS_PVCOLUMNS.COUNT+1;

	IF WS_SAIDA <> 'O' AND WS_SAIDA <> 'C' THEN
		HTP.P('<th rowspan="'||WS_ROW||'" colspan="1" class="fix" title="'||FUN.LANG('alterar de subquery para sele&ccedil;&atilde;o de linha')||'" onclick=" var setas = document.getElementById('''||WS_OBJ||'c'').querySelectorAll(''.seta, .setadown, .checked''); for(let i = 0; i < setas.length; i++){ setas[i].classList.remove(''checked''); if(setas[i].className.indexOf(''setadown'') != -1){ setas[i].classList.remove(''setadown''); setas[i].classList.add(''seta''); } else { setas[i].classList.remove(''seta''); setas[i].classList.add(''setadown''); } }"></th>');
        ws_qt_cab_agru := ws_qt_cab_agru + 1; 
	END IF;

	BEGIN
    	LOOP
			WS_COUNTER := WS_COUNTER+1;
			WS_COUNTERID := WS_COUNTERID+1;

			IF  WS_COUNTER > WS_NCOLUMNS.COUNT-2 THEN
				EXIT;
			END IF;

			WS_CCOLUNA := 1;

			LOOP
				IF WS_CCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
					EXIT;
				END IF;

				WS_CCOLUNA := WS_CCOLUNA + 1;
			END LOOP;

			IF  RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' THEN

			    WS_COUNT := WS_PVCOLUMNS.COUNT+1;

				SELECT COUNT(*) INTO WS_COUNT_V FROM TABLE(FUN.VPIPE((WS_ARR(53)))) WHERE COLUMN_VALUE = RET_MCOL(WS_CCOLUNA).CD_COLUNA;
				WS_HINT := '';
				SELECT HINT INTO WS_HINT FROM MICRO_COLUNA WHERE CD_MICRO_VISAO = PRM_VISAO AND CD_COLUNA = RET_MCOL(WS_CCOLUNA).CD_COLUNA;

				IF NVL(WS_HINT, 'N/A') <> 'N/A' THEN
					WS_HINT := 'title="'||WS_HINT||'"';
				END IF;

					WS_FIX   := '';
					
					IF WS_FIXED > 1 AND WS_COUNTER < WS_FIXED THEN
						IF WS_COUNT_V <> 0 THEN
							WS_FIX   := ' fix inv';
							ws_inv_count := ws_inv_count+1;
							DIMENSAO_SOMA := DIMENSAO_SOMA-1;
						ELSE
							WS_FIX   := ' fix';
						END IF;
						WS_FIXED := WS_FIXED-1;
					ELSE
						IF WS_COUNT_V <> 0 THEN
							WS_FIX   := ' inv';
							DIMENSAO_SOMA := DIMENSAO_SOMA-1;
						END IF;
					END IF;
						
						IF RET_MCOL(WS_CCOLUNA).ST_COM_CODIGO = 'N' AND RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' AND RET_MCOL(WS_CCOLUNA).CD_LIGACAO <> 'SEM' AND NVL(WS_DRILL, 'N') <> 'C' THEN
							IF LENGTH(WS_REPEAT) = 4 THEN
								WS_ESTILO_LINHA := WS_ESTILO_LINHA||' div#main table#'||WS_OBJ||'c tr:nth-child(1):not(.sub) th:nth-child('||WS_COUNTERID||'), div#main table#'||PRM_OBJETO||'trlc tr:nth-child(1):not(.sub) th:nth-child('||WS_COUNTERID||'), div#main table#'||PRM_OBJETO||'c tr:not(.duplicado):not(.sub) td:nth-child('||WS_COUNTERID||'), table#'||PRM_OBJETO||'trlc tr:not(.duplicado):not(.sub) td:nth-child('||WS_COUNTERID||'), div#custom-conteudo table#'||PRM_OBJETO||'c tr:not(.duplicado):not(.sub) td:nth-child('||(WS_COUNTERID-1)||'), div#custom-conteudo table#'||PRM_OBJETO||'c tr:not(.duplicado):not(.sub) th:nth-child('||(WS_COUNTERID-1)||') { display: none; }';
								WS_REPEAT := 'hidden';
								ws_fix := ws_fix||' print';
								IF LENGTH(WS_ARR(48)) > 0 THEN
								    DIMENSAO_SOMA := DIMENSAO_SOMA-1;
								END IF;
							END IF;
						
						END IF;

						DIMENSAO_SOMA := DIMENSAO_SOMA+1;

						SELECT PROP INTO WS_ORDEM FROM(
							SELECT PROP FROM (
							SELECT UPPER(PROPRIEDADE) AS PROP, OWNER ORDEM FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJETO AND CD_PROP = 'ORDEM' AND OWNER IN (WS_USUARIO, 'DWU')
							UNION ALL
							SELECT '1', 'LAST' ORDEM FROM DUAL
							) ORDER BY DECODE(ORDEM, 'DWU', 2, 'LAST', 3, 1) 
						) WHERE ROWNUM = 1;

						BEGIN
							SELECT UPPER(REPLACE(COLUMN_VALUE, RET_MCOL(WS_CCOLUNA).CD_COLUNA, '')) INTO WS_ORDEM_ARROW FROM TABLE((FUN.VPIPE(WS_ORDEM, ','))) WHERE TRIM(COLUMN_VALUE) LIKE (WS_COUNTER||' %');
						EXCEPTION WHEN OTHERS THEN
							WS_ORDEM_ARROW := '';
						END;
						
							IF RTRIM(RET_MCOL(WS_CCOLUNA).ST_INVISIVEL) = 'S' THEN
								IF WS_SAIDA <> 'O' THEN
									HTP.PRN('<th rowspan="'||WS_COUNT||'" class="'||WS_ORDEM_ARROW||' '||WS_FIX||'" colspan="'||WS_CSPAN||'" '||WS_JUMP||' class="no_font" '||WS_HINT||'>');
									ws_qt_cab_agru := ws_qt_cab_agru + ws_cspan; 
								END IF;
							ELSE
								IF WS_SAIDA <> 'O' THEN
									HTP.PRN('<th rowspan="'||WS_COUNT||'" class="'||WS_ORDEM_ARROW||WS_FIX||'" colspan="1" '||WS_JUMP||' '||WS_HINT||' >');
									ws_qt_cab_agru := ws_qt_cab_agru + 1; 
								END IF;
							END IF; 

							IF WS_SAIDA <> 'O' THEN
								IF (WS_CONTENT_ANT = RET_MCOL(WS_CCOLUNA).NM_ROTULO) OR (RET_MCOL(WS_CCOLUNA).CD_LIGACAO = 'SEM') THEN
								    HTP.PRN(FUN.UTRANSLATE('NM_ROTULO', PRM_VISAO, FUN.CHECK_ROTULOC(RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_VISAO, PRM_SCREEN), WS_PADRAO));
								ELSE
									HTP.PRN('#');
								END IF;
							END IF;

							IF WS_SAIDA <> 'O' THEN
								HTP.PRN('</th>');
							END IF;

							IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
								FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA ,'<Cell><Data ss:Type="String">'||REPLACE(FUN.PTG_TRANS(FUN.UTRANSLATE('NM_ROTULO', PRM_VISAO, FUN.CHECK_ROTULOC(RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_VISAO, PRM_SCREEN), WS_PADRAO)), '<BR>', ' ')||'</Data></Cell>', '', '');
							END IF;

							
							--COMENTADO E APLICADO EMBAIXO UMA ALTERAÇÃO PARA QUE A COR DA COLUNA APLIQUE NAS DRILLS TB. 14/04/22
							--WS_ESTILO_LINHA := WS_ESTILO_LINHA||' div#main table#'||WS_OBJ||'c tr:not(.total.geral) td:nth-child('||(WS_COUNTER+1)||') { background-color: '||RET_MCOL(WS_CCOLUNA).COLOR||'; }';
							ws_estilo_linha := ws_estilo_linha||' div#main table#'||ws_obj||'c tr:not(.total):not(.geral):not(.destaqueLinha) td:nth-child('||(ws_counter+1)||'),div#main table#'||ws_obj||'trlc tr:not(.total):not(.geral):not(.destaqueLinha) td:nth-child('||(ws_counter+1)||') { background-color: '||ret_mcol(ws_ccoluna).color||'; }';
						IF NVL(RET_MCOL(WS_CCOLUNA).URL, 'N/A') <> 'N/A' THEN
							HTP.PRN('<th rowspan="'||WS_COUNT||'"></th>');
							DIMENSAO_SOMA := DIMENSAO_SOMA+1;
							WS_CSPAN := WS_CSPAN+1;
						END IF;

                    IF WS_CONTENT_ANT = RET_MCOL(WS_CCOLUNA).NM_ROTULO THEN
					    
					    WS_REPEAT := 'show';
					END IF;

				

			END IF;

	    	WS_CONTENT_ANT := RET_MCOL(WS_CCOLUNA).NM_ROTULO;

		END LOOP;

    EXCEPTION WHEN OTHERS THEN
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - ERROCOUNT', WS_USUARIO, 'ERRO');
        COMMIT;
    END;

	WS_COUNT := 0;
	WS_BINDN  := 0;

	LOOP

		WS_BINDN := WS_BINDN + 1;
	    IF  WS_BINDN > WS_PVCOLUMNS.COUNT THEN
		    EXIT;
	    END IF;

		IF WS_BINDN > 1 THEN
		    HTP.P('<tr title="2">');
        END IF;

	    WS_PCURSOR   := DBMS_SQL.OPEN_CURSOR;

		BEGIN
			DBMS_SQL.PARSE(WS_PCURSOR, WS_SQL_PIVOT, DBMS_SQL.NATIVE);
		EXCEPTION
			WHEN OTHERS THEN
				RAISE WS_SEMQUERY;
		END;

	    WS_COUNTER := 0;
	    LOOP
	    	WS_COUNTER := WS_COUNTER + 1;
	    	IF  WS_COUNTER > WS_PVCOLUMNS.COUNT THEN
	    	    EXIT;
	    	END IF;

			DBMS_SQL.DEFINE_COLUMN(WS_PCURSOR, WS_COUNTER, RET_COLUP, 3000);

		END LOOP;

		WS_CCOLUNA := 1;

	    LOOP
			IF  WS_CCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_PVCOLUMNS(WS_BINDN) THEN
				EXIT;
			END IF;
			WS_CCOLUNA := WS_CCOLUNA + 1;
	    END LOOP;

	    WS_BINDS := CORE.BIND_DIRECT(WS_PARAMETROS, WS_PCURSOR, '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN);
		
		WS_BINDS := REPLACE(WS_BINDS, 'Binds Carregadas=|', '');
		
	    WS_LINHAS := DBMS_SQL.EXECUTE(WS_PCURSOR);
        
		WS_COUNT_V := 0;
		SELECT COUNT(*) INTO WS_COUNT_V FROM TABLE(FUN.VPIPE((WS_ARR(53)))) WHERE COLUMN_VALUE IN (SELECT COLUMN_VALUE FROM TABLE(FUN.VPIPE((SELECT CS_AGRUPADOR FROM PONTO_AVALIACAO WHERE CD_PONTO = PRM_OBJETO))));

		WS_CONTENT_ANT    := '%First%';
		WS_COL_SUP_ANT := '%First%';
	    WS_XCOUNT         := 0;

		LOOP

		    WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_PCURSOR);
		    IF  WS_LINHAS <> 1 THEN
		        IF WS_SAIDA <> 'O' THEN
				    
					IF WS_BINDN <> WS_PVCOLUMNS.COUNT THEN
			            
						WS_COUNT := 0;

						NESTED_CALCULADA(WS_ARR(5), '', '', WS_COUNT);
						
						WS_COLSPAN := ((WS_XCOUNT*WS_SCOL)+WS_COUNT)-(WS_COUNT_V*WS_XCOUNT);

                        
						HTP.PRN('<th style="text-align:center !important;" colspan="'||WS_COLSPAN||'">');
						
							IF  RET_MCOL(WS_CCOLUNA).CD_LIGACAO <> 'SEM' THEN
								IF  RET_MCOL(WS_CCOLUNA).ST_COM_CODIGO = 'S' THEN
									WS_CONTENT_ANT := WS_CONTENT_ANT||'-'||FUN.CDESC(WS_CONTENT_ANT,RET_MCOL(WS_CCOLUNA).CD_LIGACAO);
								ELSE
									WS_CONTENT_ANT := FUN.CDESC(WS_CONTENT_ANT,RET_MCOL(WS_CCOLUNA).CD_LIGACAO);
								END IF;
							END IF;

							BEGIN 
								HTP.P(TRIM(FUN.UTRANSLATE('NM_ROTULO', PRM_VISAO, FUN.IFMASCARA(WS_CONTENT_ANT, RET_MCOL(WS_CCOLUNA).NM_MASCARA, PRM_VISAO, PRM_COLUNA, '', '', '', ''), WS_PADRAO)));
							EXCEPTION WHEN OTHERS THEN
								HTP.P(TRIM(FUN.UTRANSLATE('NM_ROTULO', PRM_VISAO, WS_CONTENT_ANT, WS_PADRAO)));
							END;

						HTP.P('</th>');
						
					
					END IF;
				END IF;

			    EXIT;
		    END IF;

		    DBMS_SQL.COLUMN_VALUE(WS_PCURSOR, WS_BINDN, RET_COLUNA);
			
			IF WS_BINDN > 1 THEN
			    
			    DBMS_SQL.COLUMN_VALUE(WS_PCURSOR, WS_BINDN-1, WS_COL_SUP);
			END IF;

			
		    
			IF  WS_CONTENT_ANT = '%First%' OR (WS_BINDN = WS_PVCOLUMNS.COUNT) THEN
		        WS_CONTENT_ANT := RET_COLUNA;
		    END IF;

            
			IF  WS_COL_SUP_ANT = '%First%' THEN
		        WS_COL_SUP_ANT := WS_COL_SUP;
		    END IF;

            
			IF  WS_BINDN = WS_PVCOLUMNS.COUNT THEN
				WS_XCOUNT := 1;
			END IF;
			
		    IF (WS_CONTENT_ANT <> RET_COLUNA OR WS_COL_SUP_ANT <> WS_COL_SUP) OR WS_BINDN = WS_PVCOLUMNS.COUNT THEN
		        IF WS_SAIDA <> 'O' THEN
				    WS_COUNT := 0;
						
						NESTED_CALCULADA(WS_ARR(5), '', '', WS_COUNT);

						WS_COLSPAN := ((WS_XCOUNT*WS_SCOL)+WS_COUNT)-(WS_COUNT_V*WS_XCOUNT);

                        
						HTP.PRN('<th style="text-align:center !important;" colspan="'||WS_COLSPAN||'">');
						
						IF RET_MCOL(WS_CCOLUNA).CD_LIGACAO <> 'SEM' THEN
							IF  RET_MCOL(WS_CCOLUNA).ST_COM_CODIGO = 'S' THEN
								WS_CONTENT_ANT := WS_CONTENT_ANT||'-'||FUN.CDESC(WS_CONTENT_ANT,RET_MCOL(WS_CCOLUNA).CD_LIGACAO);
							ELSE
								WS_CONTENT_ANT := FUN.CDESC(WS_CONTENT_ANT,RET_MCOL(WS_CCOLUNA).CD_LIGACAO);
							END IF;
						END IF;

						BEGIN
							HTP.PRN(TRIM(FUN.UTRANSLATE('NM_ROTULO', PRM_VISAO, FUN.IFMASCARA(WS_CONTENT_ANT,RET_MCOL(WS_CCOLUNA).NM_MASCARA, PRM_VISAO, PRM_COLUNA, '', '', '', '', WS_USUARIO), WS_PADRAO)));
						EXCEPTION WHEN OTHERS THEN
							HTP.PRN(TRIM(FUN.UTRANSLATE('NM_ROTULO', PRM_VISAO, WS_CONTENT_ANT, WS_PADRAO)));
						END;
						HTP.P('</th>');
						
				END IF;
				WS_XCOUNT := 0;
		    END IF;

            WS_XCOUNT      := WS_XCOUNT + 1;
  
            
		    WS_CONTENT_ANT    := RET_COLUNA;
			WS_COL_SUP_ANT := WS_COL_SUP;
	    END LOOP;

		WS_XCOUNT      := 1;

        NESTED_CALCULADA(WS_ARR(5), '', '', WS_XCOUNT);

		IF (WS_SAIDA <> 'O' AND WS_ARR(40) <> 'S') AND WS_SAIDA <> 'C' THEN
			
			WS_COUNTER := WS_XCOUNT*WS_SCOL-WS_COUNT_V;
			HTP.PRN('<th style="text-align:center !important;" colspan="'||WS_COUNTER||'">'||WS_ARR(37)||'</th>');
			IF WS_ROW > 1 THEN
			    HTP.P('</tr>');
			END IF;
		END IF;

		DBMS_SQL.CLOSE_CURSOR(WS_PCURSOR);

	END LOOP;

	IF WS_SAIDA <> 'O' AND WS_ROW > 1 THEN
	    HTP.P('<tr title="3">');
	else 
	    ws_qt_cab_agru := 0;   -- Se tem somente uma linha de cabeçalho, não deve reduzir a quantidade de colunas não agrupadoras   	
	END IF;

	WS_COUNTER := 0;
	WS_CCOLUNA := 0;

	SELECT COUNT(*) INTO WS_DISTINCTMED FROM TABLE(FUN.VPIPE((SELECT CS_AGRUPADOR FROM PONTO_AVALIACAO WHERE CD_PONTO = PRM_OBJETO)));

	IF WS_DISTINCTMED = 1 THEN
	    SELECT COUNT(COLUMN_VALUE) INTO WS_DISTINCTMED FROM TABLE(FUN.VPIPE((SELECT FORMULA FROM MICRO_COLUNA WHERE ST_AGRUPADOR = 'TPT' AND CD_MICRO_VISAO = PRM_OBJETO AND CD_COLUNA = (SELECT CS_AGRUPADOR FROM PONTO_AVALIACAO WHERE CD_PONTO = PRM_OBJETO)))) WHERE COLUMN_VALUE IN (SELECT NVL(COLUMN_VALUE, 'N/A') FROM TABLE(FUN.VPIPE((SELECT PROPRIEDADE FROM OBJECT_ATTRIB WHERE CD_PROP = 'TPT' AND OWNER = WS_USUARIO AND CD_OBJECT = PRM_AGRUPADOR))));
	END IF;

	WS_COL_VALOR := 0;

	LOOP
	    WS_COUNTER   := WS_COUNTER + 1;
	    IF WS_ARR(40) <> 'S' OR WS_PVCOLUMNS.COUNT = 0 THEN
			IF WS_COUNTER > WS_NCOLUMNS.COUNT-2 THEN
				EXIT;
			END IF;
		ELSE
		    IF WS_COUNTER > WS_NCOLUMNS.COUNT-2 THEN
				EXIT;
			END IF;
		END IF;

	    WS_CCOLUNA := 1;
		
	    LOOP
			IF  WS_CCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
				EXIT;
			END IF;
			WS_CCOLUNA := WS_CCOLUNA + 1;
	    END LOOP;
       
	   	WS_HINT := '';
       
	    IF NVL(RET_MCOL(WS_CCOLUNA).HINT, 'N/A') <> 'N/A' THEN
			WS_HINT := 'title="'||RET_MCOL(WS_CCOLUNA).HINT||'" ';
		END IF;
		
		WS_HTML := '';
		
	    IF  RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR <> 'SEM' THEN
	        
			SELECT COUNT(*) INTO WS_COUNT_V FROM TABLE(FUN.VPIPE((WS_ARR(53)))) WHERE COLUMN_VALUE = RET_MCOL(WS_CCOLUNA).CD_COLUNA;

			IF LENGTH(WS_ARR(5)) > 0 THEN
				FOR I IN (SELECT COLUMN_VALUE AS VALOR, ROWNUM AS LINHA FROM TABLE(FUN.VPIPE((WS_ARR(5))))) LOOP
					IF INSTR(I.VALOR, '<') > 0 THEN
						IF SUBSTR(I.VALOR, 0, INSTR(I.VALOR, '<')-1) = RET_MCOL(WS_CCOLUNA).CD_COLUNA THEN
							SELECT NOME INTO WS_CALCULADA_N FROM(SELECT COLUMN_VALUE AS NOME, ROWNUM AS LINHA FROM TABLE(FUN.VPIPE((WS_ARR(7))))) WHERE LINHA = I.LINHA;
							WS_COUNTERID := WS_COUNTERID+1;
							HTP.PRN('<th style="text-align: center;">'||WS_CALCULADA_N||'</th>');
						END IF;
					END IF;
				END LOOP;
			END IF;

			WS_COUNTERID := WS_COUNTERID + 1;
			
			BEGIN
				SELECT REPLACE(COLUMN_VALUE, RET_MCOL(WS_CCOLUNA).CD_COLUNA, '') INTO WS_ORDEM_ARROW FROM TABLE((FUN.VPIPE(WS_ORDEM, ','))) WHERE TRIM(COLUMN_VALUE) LIKE (WS_COUNTER||' %');
			EXCEPTION WHEN OTHERS THEN
			    WS_ORDEM_ARROW := '';
			END;

			WS_HTML := WS_HTML||NVL(WS_ARR(36), FUN.UTRANSLATE('NM_ROTULO', PRM_VISAO, REPLACE(FUN.CHECK_ROTULOC(RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_VISAO, PRM_SCREEN), '(BR)', ' &#013;&#010; '), WS_PADRAO));

			WS_COL_VALOR := WS_COL_VALOR+1;

			IF WS_COUNT_V = 0 THEN

				IF WS_SAIDA <> 'O' THEN 

				    IF(TRIM(RET_MCOL(WS_CCOLUNA).ST_INVISIVEL) = 'S') THEN
						WS_CLASSE := 'no_font';
					ELSE
						WS_CLASSE := WS_ORDEM_ARROW;
					END IF;

                    BEGIN
						
						
						IF WS_ARR(40) <> 'S' THEN
							IF WS_COUNTER+WS_SCOL < WS_NCOLUMNS.COUNT-1 THEN
								BEGIN
									WS_PIVOT := 'data-pivot="'||TRIM(WS_MFILTRO(WS_COUNTER+1))||'"';
								EXCEPTION WHEN OTHERS THEN
									WS_PIVOT := '';
								END;
							ELSE
								WS_PIVOT := '';
							END IF;
						ELSE
							IF WS_COUNTER < WS_NCOLUMNS.COUNT-1 THEN
								BEGIN
									WS_PIVOT := 'data-pivot="'||TRIM(WS_MFILTRO(WS_COUNTER+1))||'"';
								EXCEPTION WHEN OTHERS THEN
									WS_PIVOT := '';
								END;
							ELSE
								WS_PIVOT := '';
							END IF;
						END IF;
					EXCEPTION WHEN OTHERS THEN
						WS_PIVOT := '';
					END;

					IF LENGTH(WS_ARR(1)) > 0 THEN
						WS_CLASSE := WS_CLASSE||' callmed';
					END IF;

				    HTP.PRN('<th '||WS_SUBQUERY||' '||WS_PIVOT||' data-ordem="1" data-valor="'||RET_MCOL(WS_CCOLUNA).CD_COLUNA||'" class="'||TRIM(WS_CLASSE)||'" '||WS_HINT||' >'||WS_HTML||'</th>');
					
					---COMENTADO E APLICADO EMBAIXO UMA ALTERAÇÃO PARA QUE A COR DA COLUNA APLIQUE NAS DRILLS TB. 14/04/22
					---WS_ESTILO_LINHA := WS_ESTILO_LINHA||' div#main table#'||PRM_OBJETO||'c tr:not(.total.geral) td:nth-child('||(WS_COUNTER+1)||') { background-color: '||RET_MCOL(WS_CCOLUNA).COLOR||'; }';
					
					-- criado a regra para não estourar a variavel ws_estilo_linha 30-05-22
					if nvl(trim(ret_mcol(ws_ccoluna).color),'N/A')<>'N/A' then
						ws_estilo_linha := ws_estilo_linha||' div#main table#'||prm_objeto||'c tr:not(.total):not(.geral):not(.destaqueLinha) td:nth-child('||(ws_counter+1)||'),div#main table#'||prm_objeto||'trlc tr:not(.total):not(.geral):not(.destaqueLinha) td:nth-child('||(ws_counter+1)||') { background-color: '||ret_mcol(ws_ccoluna).color||'; }';				
					end if;

				END IF;

				WS_HTML := '';

			END IF;

			IF LENGTH(WS_ARR(5)) > 0 THEN
				FOR I IN(SELECT COLUMN_VALUE AS VALOR, ROWNUM AS LINHA FROM TABLE(FUN.VPIPE((WS_ARR(5))))) LOOP
					IF INSTR(I.VALOR, '>') > 0 THEN
						IF SUBSTR(I.VALOR, 0, INSTR(I.VALOR, '>')-1) = RET_MCOL(WS_CCOLUNA).CD_COLUNA THEN
							SELECT NOME INTO WS_CALCULADA_N FROM(SELECT COLUMN_VALUE AS NOME, ROWNUM AS LINHA FROM TABLE(FUN.VPIPE((WS_ARR(7))))) WHERE LINHA = I.LINHA;
							WS_COUNTERID := WS_COUNTERID+1;
							HTP.PRN('<th class="cen">'||WS_CALCULADA_N||'</th>');
						END IF;
					END IF;
				END LOOP;
			END IF;

			IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
				FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA ,'<Cell><Data ss:Type="String">'||REPLACE(FUN.PTG_TRANS(FUN.UTRANSLATE('NM_ROTULO', PRM_VISAO, FUN.CHECK_ROTULOC(RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_VISAO, PRM_SCREEN), WS_PADRAO)), '<BR>', '')||'</Data></Cell>', '', '');
			END IF;

		END IF;

	END LOOP;

	WS_STEP := WS_COUNTER;
	IF WS_ARR(40) <> 'S' OR PRM_DRILL = 'C' THEN
	    WS_STEPPER := WS_SCOL;
	END IF;

    IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
	    FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '</Row>', '', '');
	END IF;

	IF WS_SAIDA <> 'O' THEN
		HTP.P('</tr>');
		HTP.P('</thead>');
	END IF;

	WS_REPEAT := 'show';
	WS_FIRSTID := 'Y';

    WS_AGRUP_MAX  :=0;

	-- retirado o if daqui e colocado no BEGIN

    /*IF WS_ARR(43) = 'S' THEN
	    WS_TEMPO := SYSDATE;
	END IF;*/

	WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE( C => WS_CURSOR, STATEMENT => WS_QUERY_MONTADA, LB => 1, UB => WS_LQUERY, LFFLG => TRUE, LANGUAGE_FLAG => DBMS_SQL.NATIVE );

	WS_BINDS := CORE.BIND_DIRECT(WS_PARAMETROS, WS_CURSOR, '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN);
    WS_BINDS := REPLACE(WS_BINDS, 'Binds Carregadas=|', '');

	WS_COUNTER := 0;

	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
	    	EXIT;
	    END IF;

		BEGIN
			IF REC_TAB(WS_COUNTER).COL_TYPE = 12 THEN
				DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, DAT_COLUNA);
			ELSE
				DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, RET_COLUNA, 2000);
			END IF;
		EXCEPTION WHEN OTHERS THEN
			DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, RET_COLUNA, 2000);
		END;
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

    WS_ZEBRADO   := 'First';
	WS_ZEBRADO_D := 'First';

	WS_HINT := '';

	HTP.PRN('<style>'||WS_ESTILO_LINHA||'</style>');
	WS_ESTILO_LINHA := '';

    
	HTP.P('<tbody>');

	LOOP
	    
		WS_COUNT := 0;
		
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
		
		WS_FIXED := NVL(WS_ARR(18), '9999')+1;
		IF LENGTH(WS_ARR(48)) > 0 AND WS_FIXED > 0 THEN
		    WS_FIXED := 999;
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
			
			BEGIN
				IF REC_TAB(WS_COUNTER).COL_TYPE = 12 THEN
					DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_CCOLUNA, DAT_COLUNA);
				ELSE
					DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_CCOLUNA, RET_COLUNA);
				END IF;
			EXCEPTION WHEN OTHERS THEN
				DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_CCOLUNA, RET_COLUNA);
			END;


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
				
				
				BEGIN
					IF REC_TAB(WS_BINDN).COL_TYPE = 12 THEN
						DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_BINDN, DAT_COLUNA);
						WS_VCON(WS_BINDN) := DAT_COLUNA;
						WS_COD_COLUNA := DAT_COLUNA;
					ELSE
						DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_BINDN, RET_COLUNA);
						WS_VCON(WS_BINDN) := RET_COLUNA;
						WS_COD_COLUNA := RET_COLUNA;
					END IF;
				EXCEPTION WHEN OTHERS THEN
					DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_BINDN, RET_COLUNA);
					WS_VCON(WS_BINDN) := RET_COLUNA;
					WS_COD_COLUNA := RET_COLUNA;
				END;
				
				
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

			IF PRM_DRILL = 'C' THEN
				WS_AMOSTRA := PRM_ZINDEX;
			ELSE
				WS_AMOSTRA := TO_NUMBER(WS_ARR(3));
			END IF;
			
			IF (WS_LINHA > WS_AMOSTRA AND WS_AMOSTRA <> 0) THEN
				EXIT;
			END IF;

			IF INSTR(RET_COLUNA, '[LC]') > 0 THEN
				WS_LINHA_CALC := ' lc';  
				RET_COLUNA := REPLACE(RET_COLUNA, '[LC]', '');
				WS_XATALHO := REPLACE(WS_XATALHO, '[LC]', '');
			ELSE
				WS_LINHA_CALC := ''; 
			END IF;
		

		IF RET_COLGRP = 0 THEN
			IF WS_ZEBRADO = 'Escuro'  THEN
				IF WS_SAIDA <> 'O' THEN
					
					HTP.P('<tr class="es'||WS_LINHA_CALC||'">');
				END IF;
				IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
					FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '<Row>', '', '');
				END IF;
			ELSE
				IF WS_SAIDA <> 'O' THEN
					HTP.P('<tr class="cl'||WS_LINHA_CALC||'">');
				END IF;
				IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
					FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '<Row>', '', '');
				END IF;
			END IF;
		ELSE
			IF WS_SAIDA <> 'O' THEN
				
				IF WS_ARR(51) = 'bold' THEN
                    WS_JUMP := ' bld';
				END IF;
				
				IF RET_COLTOT = 1 THEN
					HTP.P('<tr class="total geral st-'||WS_ARR(41)||WS_JUMP||'" data-drill="'||WS_ARR(15)||'">');
				ELSE
                    IF WS_ARR(44) <> 'S' OR PRM_DRILL = 'C' THEN
					    HTP.P('<tr class="total normal st-'||WS_ARR(44)||WS_JUMP||'">');
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

		WS_DRILL_A := REPLACE('|'||TRIM(WS_XATALHO),'||','|');

		IF(INSTR(WS_DRILL_A, '|', 1, 1) = 1) THEN
			WS_DRILL_A := SUBSTR(WS_DRILL_A,2,LENGTH(WS_DRILL_A));
		END IF;

		WS_JUMP := WS_TMP_JUMP;

		WS_COD_COLUNA := RET_COLUNA;

		WS_FIX   := '';
		
		IF WS_FIXED > 1 THEN
			WS_FIX   := 'fix';
		END IF;

		IF RET_COLGRP = 0 THEN
			IF WS_SAIDA <> 'O' THEN --AND WS_SAIDA <> 'C' THEN
			    
				HTP.P('<td '||WS_CHECK||' title="'||RET_COLUNA||'" class="'||WS_JUMP||' '||WS_FIX||'" '||WS_SUBQUERY||' data-ordem="1" data-valor="'||WS_DRILL_A||'"></td>');
			END IF;
		ELSE

			IF RET_COLTOT = 1 THEN
				IF WS_SAIDA <> 'O' THEN
					HTP.P('<td data-valor="'||WS_DRILL_A||'" data-drill="'||WS_SAIDA||'" class="dir '||WS_FIX||'"></td>');
					IF LENGTH(WS_ARR(48)) > 0 THEN
					    HTP.P('<td colspan="'||DIMENSAO_SOMA||'" data-valor="'||WS_DRILL_A||'" class="dir '||WS_FIX||'" style="display: table-cell;">'||WS_ARR(48)||'</td>');
				    ELSE
					    IF WS_SAIDA <> 'C' THEN
							FOR L IN 1..DIMENSAO_SOMA LOOP
														
								WS_FIX := '';
								IF WS_FIXED > 1 THEN
									WS_FIX   := 'fix';
								END IF;
								
								HTP.P('<td data-valor="'||WS_DRILL_A||'" class="'||WS_FIX||'"></td>');
								
							END LOOP;
							FOR z IN 1..ws_inv_count LOOP
								HTP.P('<td data-valor="'||WS_DRILL_A||'" class="inv"></td>');
							END LOOP;
						ELSE
                            
							FOR L IN 1..DIMENSAO_SOMA-1 LOOP
								
								WS_FIX := '';
								IF WS_FIXED > 1 THEN
									WS_FIX   := 'fix';
									WS_FIXED := WS_FIXED-1;
								END IF;
								
								HTP.P('<td data-valor="'||WS_DRILL_A||'" class="'||WS_FIX||'"></td>');
								
							END LOOP;
							FOR z IN 1..ws_inv_count LOOP
								HTP.P('<td data-valor="'||WS_DRILL_A||'" class="inv"></td>');
							END LOOP;
						END IF;
					END IF;
				ELSE

				    IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
						FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA ,'<Cell> <Data ss:Type="String">'||WS_ARR(48)||'</Data></Cell>', '', '');
					END IF;

					FOR L IN 1..DIMENSAO_SOMA LOOP
                        FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA ,'<Cell> <Data ss:Type="String"></Data></Cell>', '', '');
					END LOOP;

				END IF;
			ELSE
				IF WS_SAIDA <> 'O' THEN
				    IF WS_ARR(44) <> 'S' AND WS_SAIDA <> 'C' THEN
					    HTP.P('<td data-valor="'||WS_DRILL_A||'" class="'||WS_FIX||'"></td>');
					END IF;
				END IF;
			END IF;

		END IF;

		WS_COUNTER := 0;  

		LOOP

			WS_FIX := '';
								
			IF WS_FIXED > 1 THEN
				IF WS_COUNT_V <> 0 THEN
					WS_FIX   := 'fix inv';
				ELSE
					WS_FIX   := 'fix';
				END IF;
				WS_FIXED := WS_FIXED-1;
			ELSE
				IF WS_COUNT_V <> 0 THEN
					WS_FIX   := 'inv';
				END IF;
			END IF;

			WS_COUNTER := WS_COUNTER + 1;

			BEGIN
				WS_COUNT_V := 0;
				SELECT COUNT(*) INTO WS_COUNT_V FROM TABLE(FUN.VPIPE((WS_ARR(53)))) WHERE COLUMN_VALUE = RET_MCOL(WS_CCOLUNA).CD_COLUNA;

				IF WS_COUNT_V = 0 THEN
					WS_CHILD := WS_CHILD+1;
				END IF;
			EXCEPTION WHEN OTHERS THEN
				WS_COUNT_V := 0;
			END;

			IF WS_ARR(40) <> 'S' OR WS_PVCOLUMNS.COUNT = 0 THEN
				IF WS_COUNTER > WS_NCOLUMNS.COUNT-2 THEN
					EXIT;
				END IF;
			ELSE
			    IF WS_COUNTER > WS_NCOLUMNS.COUNT-2 THEN
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

				IF WS_CCOLUNA > RET_MCOL.COUNT THEN
					WS_CCOLUNA := WS_CCOLUNA - 1;
					EXIT;
				END IF;

				IF RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER)  THEN
					EXIT;
				END IF;

				WS_CCOLUNA := WS_CCOLUNA + 1;

			END LOOP;

			BEGIN

				IF REC_TAB(WS_COUNTER).COL_TYPE = 12 THEN
					DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_COUNTER, DAT_COLUNA);
					IF RET_MCOL(WS_CCOLUNA).NM_MASCARA = 'SEM' THEN
						WS_CONTENT := TO_CHAR(DAT_COLUNA, 'DD/MM/YYYY HH24:MI');
					ELSE
						WS_CONTENT := DAT_COLUNA;
					END IF;
				ELSE
					BEGIN
						DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_COUNTER, RET_COLUNA);
					EXCEPTION WHEN OTHERS THEN
						DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_COUNTER, RET_COLUNA);
					END;

					--WS_CONTENT := REPLACE(RET_COLUNA,'"','*');
					WS_CONTENT := REPLACE(RET_COLUNA,'"','"');
					WS_CONTENT := REPLACE(WS_CONTENT,'/','&#47;');
				
				END IF;
				
			EXCEPTION WHEN OTHERS THEN
				DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_COUNTER, RET_COLUNA);
				WS_CONTENT := RET_COLUNA;
			END;	

			IF INSTR(WS_CONTENT, '[LC]') > 0 THEN 
			    WS_CONTENT := REPLACE(WS_CONTENT, '[LC]', '');
		
		    END IF;		

			BEGIN
				IF WS_LINHA > 1 THEN
				    IF TRIM(RET_COLUNA) = TRIM(WS_ARRAY_ANTERIOR(WS_COUNTER)) AND WS_ARR(35) = 'S' AND RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' THEN
						WS_CONTENT := '';
					END IF;
				END IF;
			EXCEPTION WHEN OTHERS THEN
				HTP.P(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			END;

			IF WS_FIRSTID = 'Y' THEN
				WS_IDCOL := 'id="'||WS_OBJ||WS_COUNTER||'l" ';
			ELSE
				WS_IDCOL := '';
			END IF;

			WS_DRILL_A := REPLACE(TRIM(WS_ATALHO)||'|'||TRIM(WS_XATALHO),'||','|');
			
			IF(INSTR(WS_DRILL_A, '|', 1, 1) = 1) THEN
				WS_DRILL_A := SUBSTR(WS_DRILL_A,2,LENGTH(WS_DRILL_A));
			END IF;

			WS_JUMP := '';

			IF(LENGTH(WS_JUMP) > 1) THEN
			  WS_JUMP := 'style="'||WS_JUMP||'"';
			END IF;

			IF RTRIM(RET_MCOL(WS_CCOLUNA).ST_INVISIVEL) <> 'S' THEN

				IF RTRIM(SUBSTR(RET_MCOL(WS_CCOLUNA).FORMULA,1,8))='FLEXCOL=' THEN
					BEGIN
						WS_TEXTO_AL     := REPLACE(RET_MCOL(WS_CCOLUNA).FORMULA,'FLEXCOL=','');
						WS_NM_VAR_AL    := SUBSTR(WS_TEXTO_AL, 1 ,INSTR(WS_TEXTO_AL,'|')-1);
						WS_CD_COLUNA := FUN.GPARAMETRO(TRIM(WS_NM_VAR_AL), PRM_SCREEN => PRM_SCREEN);
						SELECT NVL(ST_ALINHAMENTO, 'LEFT') INTO WS_ALINHAMENTO
						FROM MICRO_COLUNA
						WHERE CD_MICRO_VISAO = PRM_VISAO AND
						CD_COLUNA = WS_CD_COLUNA;
					EXCEPTION WHEN OTHERS THEN
						WS_ALINHAMENTO := RET_MCOL(WS_CCOLUNA).ST_ALINHAMENTO;
					END;
				ELSE
					WS_ALINHAMENTO := RET_MCOL(WS_CCOLUNA).ST_ALINHAMENTO;
				END IF;

			ELSE
				WS_JUMP := WS_JUMP||' class="no_font"';
			END IF;

			IF WS_CONTENT = '"' THEN
				WS_JUMP := WS_JUMP||' class="cen"';
			END IF;

			WS_JUMP := TRIM(WS_JUMP);

			
			IF WS_ARR(34) = 'S' AND RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR <> 'SEM' AND WS_COUNTER < WS_NCOLUMNS.COUNT AND RET_COLGRP = 0  THEN
				IF WS_COUNTER > WS_ARR(9) AND WS_COUNTER < (WS_NCOLUMNS.COUNT-WS_ARR(8)) AND WS_SCOL = 1 THEN
					BEGIN
						WS_TEMP_VALOR := TO_NUMBER(NVL(RET_COLUNA, '0'));
					EXCEPTION WHEN OTHERS THEN
						WS_TEMP_VALOR := 0;
					END;

					WS_AC_LINHA := WS_AC_LINHA + WS_TEMP_VALOR;
					WS_CONTENT     := WS_AC_LINHA;
				END IF;
			END IF;

			WS_PIVOT_C := '';

			FOR I IN (SELECT CD_CONTEUDO FROM TABLE(FUN.VPIPE_PAR(TRIM(WS_ATALHO)))) LOOP
				WS_PIVOT_C := WS_PIVOT_C||'-'||REPLACE(I.CD_CONTEUDO, '|', '-');
			END LOOP;

			SELECT RET_MCOL(WS_CCOLUNA).CD_COLUNA||'-'||WS_PIVOT_C INTO WS_PIVOT_C FROM DUAL;

			IF LENGTH(WS_PIVOT_C) = LENGTH(RET_MCOL(WS_CCOLUNA).CD_COLUNA||'-') THEN
				WS_PIVOT_C := RET_MCOL(WS_CCOLUNA).CD_COLUNA;
			END IF;

			WS_PIVOT_C := REPLACE(WS_PIVOT_C, '--', '-');
			
			WS_HINT := '';
			
			IF NVL(RET_MCOL(WS_CCOLUNA).LIMITE, 0) > 0 AND LENGTH(WS_CONTENT) > NVL(RET_MCOL(WS_CCOLUNA).LIMITE, 0) THEN
				WS_HINT := WS_CONTENT;
				WS_CONTENT := SUBSTR(WS_CONTENT, 0, RET_MCOL(WS_CCOLUNA).LIMITE);
			END IF;
			
			IF NVL(WS_HINT, 'N/A') <> 'N/A' THEN
				WS_HINT := 'title="'||WS_HINT||'" ';
			END IF;

			WS_FIX   := '';

			SELECT COUNT(*) INTO WS_COUNT_V FROM TABLE(FUN.VPIPE((WS_ARR(53)))) WHERE COLUMN_VALUE = RET_MCOL(WS_CCOLUNA).CD_COLUNA;
			
			IF WS_FIXED > 1 THEN
				IF WS_COUNT_V = 0 THEN
					WS_FIX   := 'class="fix" ';
				ELSE
					WS_FIX   := 'class="fix inv" ';
				END IF;
			ELSE
				IF WS_COUNT_V <> 0 THEN
					WS_FIX   := 'class="inv" ';
				END IF;
			END IF;

				IF RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' AND WS_CONTENT = WS_COLUNA_ANT(WS_COUNTER) THEN
					IF LENGTH(WS_REPEAT) = 4 THEN
						IF WS_SAIDA <> 'O' THEN
								
								IF RET_COLGRP <> 0 THEN  
									IF WS_ARR(44) <> 'S' OR PRM_DRILL = 'C' THEN
										
										NESTED_TD(WS_HINT, WS_FIX, WS_COUNTER, WS_IDCOL, PRM_OBJETO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT, PRM_SCREEN, RET_MCOL(WS_CCOLUNA).FORMULA, PRM_VISAO,RET_MCOL(WS_CCOLUNA).NM_MASCARA, WS_JUMP, RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR);
									END IF;
								ELSE
									
									NESTED_TD(WS_HINT, WS_FIX, WS_COUNTER, WS_IDCOL, PRM_OBJETO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT, PRM_SCREEN, RET_MCOL(WS_CCOLUNA).FORMULA, PRM_VISAO,RET_MCOL(WS_CCOLUNA).NM_MASCARA, WS_JUMP, RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR);
								END IF;

							IF NVL(RET_MCOL(WS_CCOLUNA).URL, 'N/A') <> 'N/A' THEN
								HTP.P('<td onmouseleave="out_evento();" class="imgurl '||WS_FIX||'" data-url="'||REPLACE(REPLACE(RET_MCOL(WS_CCOLUNA).URL,'"',''), '$[DOWNLOAD]', 'dwu.fcl.download?arquivo=')||'" data-i="'||WS_COUNTER||'" '||WS_IDCOL||FUN.CHECK_BLINK(PRM_OBJETO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT, '', PRM_SCREEN, WS_USUARIO)||' '||WS_JUMP||'>');
								HTP.P('<svg style="border-radius: 2px; padding: 0px 1px; background: #DEDEDE; width: 14px;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 viewBox="0 0 58 58" style="enable-background:new 0 0 58 58;" xml:space="preserve"> <g> 	<path d="M57,6H1C0.448,6,0,6.447,0,7v44c0,0.553,0.448,1,1,1h56c0.552,0,1-0.447,1-1V7C58,6.447,57.552,6,57,6z M56,50H2V8h54V50z" 		/> 	<path d="M16,28.138c3.071,0,5.569-2.498,5.569-5.568C21.569,19.498,19.071,17,16,17s-5.569,2.498-5.569,5.569 		C10.431,25.64,12.929,28.138,16,28.138z M16,19c1.968,0,3.569,1.602,3.569,3.569S17.968,26.138,16,26.138s-3.569-1.601-3.569-3.568 		S14.032,19,16,19z"/> 	<path d="M7,46c0.234,0,0.47-0.082,0.66-0.249l16.313-14.362l10.302,10.301c0.391,0.391,1.023,0.391,1.414,0s0.391-1.023,0-1.414 		l-4.807-4.807l9.181-10.054l11.261,10.323c0.407,0.373,1.04,0.345,1.413-0.062c0.373-0.407,0.346-1.04-0.062-1.413l-12-11 		c-0.196-0.179-0.457-0.268-0.72-0.262c-0.265,0.012-0.515,0.129-0.694,0.325l-9.794,10.727l-4.743-4.743 		c-0.374-0.373-0.972-0.392-1.368-0.044L6.339,44.249c-0.415,0.365-0.455,0.997-0.09,1.412C6.447,45.886,6.723,46,7,46z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
							END IF;

						END IF;

						IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
							FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA ,'<Cell><Data ss:Type="String">'||FUN.PTG_TRANS(FUN.IFMASCARA(WS_CONTENT,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA),PRM_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJETO, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN, WS_USUARIO))||'</Data></Cell>', '', '');
						END IF;

					END IF;
				ELSE
					IF RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR = 'SEM' THEN
						IF LENGTH(WS_REPEAT) = 4 THEN
							IF RET_COLTOT = 1 AND LENGTH(WS_ARR(48)) > 0  THEN
								IF WS_SAIDA <> 'O' THEN
									IF WS_COUNTER <= DIMENSAO_SOMA+1 THEN 
									HTP.P('<td class="inv"></td>');
									WS_INV_TAG := WS_INV_TAG+1;
									END IF;
								END IF;
							ELSE
								IF WS_SAIDA <> 'O' THEN
									
									IF RET_COLTOT <> 1 THEN

										

									    IF WS_FIRSTID = 'Y' THEN
											NESTED_FIX(RET_MCOL(WS_CCOLUNA).ST_ALINHAMENTO, RET_MCOL(WS_CCOLUNA).ST_NEGRITO, WS_COUNTER, WS_ESTILO_LINHA);
										END IF;

										--htp.p(ws_fixed);

										WS_FIX   := '';
										
										IF WS_FIXED > 1 THEN
											IF WS_COUNT_V = 0 THEN
												IF LENGTH(WS_REPEAT) = 4 THEN
													WS_FIX   := 'class="fix print" ';
												else
													WS_FIX   := 'class="fix" ';
												end if;
											ELSE
												WS_FIX   := 'class="fix inv" ';
											END IF;
										ELSE
											IF WS_COUNT_V <> 0 THEN
												WS_FIX   := 'class="inv" ';
											END IF;
										END IF;

										    IF RET_COLGRP = 0 OR (WS_ARR(44) <> 'S' OR PRM_DRILL = 'C') THEN 
											    NESTED_TD(WS_HINT, WS_FIX, WS_COUNTER, WS_IDCOL, PRM_OBJETO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT, PRM_SCREEN, RET_MCOL(WS_CCOLUNA).FORMULA, PRM_VISAO,RET_MCOL(WS_CCOLUNA).NM_MASCARA, WS_JUMP, RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR);
											END IF;
										
										
										IF NVL(RET_MCOL(WS_CCOLUNA).URL, 'N/A') <> 'N/A' THEN
											HTP.P('<td onmouseleave="out_evento();" class="imgurl '||WS_FIX||'" data-url="'||REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RET_MCOL(WS_CCOLUNA).URL,'"',''), '$[DOWNLOAD]', 'dwu.fcl.download?arquivo='), '$[SELF]', WS_COD_COLUNA), CHR(39), ''), '|', '')||'" data-i="'||WS_COUNTER||'" '||WS_IDCOL||FUN.CHECK_BLINK(PRM_OBJETO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT, '', PRM_SCREEN, WS_USUARIO)||' '||WS_JUMP||'>');
											HTP.P('<svg style="border-radius: 2px; padding: 0px 1px; background: #DEDEDE; width: 14px;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 viewBox="0 0 58 58" style="enable-background:new 0 0 58 58;" xml:space="preserve"> <g> 	<path d="M57,6H1C0.448,6,0,6.447,0,7v44c0,0.553,0.448,1,1,1h56c0.552,0,1-0.447,1-1V7C58,6.447,57.552,6,57,6z M56,50H2V8h54V50z" 		/> 	<path d="M16,28.138c3.071,0,5.569-2.498,5.569-5.568C21.569,19.498,19.071,17,16,17s-5.569,2.498-5.569,5.569 		C10.431,25.64,12.929,28.138,16,28.138z M16,19c1.968,0,3.569,1.602,3.569,3.569S17.968,26.138,16,26.138s-3.569-1.601-3.569-3.568 		S14.032,19,16,19z"/> 	<path d="M7,46c0.234,0,0.47-0.082,0.66-0.249l16.313-14.362l10.302,10.301c0.391,0.391,1.023,0.391,1.414,0s0.391-1.023,0-1.414 		l-4.807-4.807l9.181-10.054l11.261,10.323c0.407,0.373,1.04,0.345,1.413-0.062c0.373-0.407,0.346-1.04-0.062-1.413l-12-11 		c-0.196-0.179-0.457-0.268-0.72-0.262c-0.265,0.012-0.515,0.129-0.694,0.325l-9.794,10.727l-4.743-4.743 		c-0.374-0.373-0.972-0.392-1.368-0.044L6.339,44.249c-0.415,0.365-0.455,0.997-0.09,1.412C6.447,45.886,6.723,46,7,46z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
										END IF;

									END IF;
								END IF;
								IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
									FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA ,'<Cell><Data ss:Type="String">'||FUN.PTG_TRANS(WS_CONTENT)||'</Data></Cell>', '', '');
								END IF;
							END IF;
						END IF;
					ELSE 
						
						IF(RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR IN ('PSM','PCT') AND RET_COLGRP <> 0) OR (RET_MCOL(WS_CCOLUNA).ST_GERA_REL = 'N' AND RET_COLGRP <> 0) THEN
							WS_CONTENT := ' ';
						END IF;

						IF RET_COLGRP <> 0 THEN
							IF WS_ARR(47) = 'S' AND WS_SCOL = 1 AND WS_ARR(49) = 'N' THEN
								IF WS_COUNTER+WS_CTNULL > WS_ARR(9)+WS_CTCOL AND WS_COUNTER < ((WS_NCOLUMNS.COUNT)-WS_ARR(8)) THEN
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
						END IF;	
							
						
						IF WS_SAIDA <> 'O' THEN
							NESTED_CALCULADA(WS_ARR(5), RET_MCOL(WS_CCOLUNA).CD_COLUNA, '<', WS_COUNT_V);

							IF WS_FIRSTID = 'Y' THEN
								NESTED_FIX(RET_MCOL(WS_CCOLUNA).ST_ALINHAMENTO, RET_MCOL(WS_CCOLUNA).ST_NEGRITO, WS_COUNTER, WS_ESTILO_LINHA);
							END IF;

							WS_FIX   := '';
							
							IF WS_COUNT_V <> 0 THEN
								WS_FIX   := 'class="inv" ';
							END IF;
							
							WS_CONTENT := NVL(WS_CONTENT, 0);

							IF (WS_ARR(44) = 'S' AND RET_COLGRP = 0) OR WS_ARR(44) = 'N' OR RET_COLTOT = 1 THEN 
								NESTED_TD(WS_HINT, WS_FIX, WS_COUNTER, WS_IDCOL, PRM_OBJETO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_CONTENT, PRM_SCREEN, RET_MCOL(WS_CCOLUNA).FORMULA, PRM_VISAO,RET_MCOL(WS_CCOLUNA).NM_MASCARA, WS_JUMP, RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR, RET_MCOL(WS_CCOLUNA).NM_UNIDADE);
							END IF;

							NESTED_CALCULADA(WS_ARR(5), RET_MCOL(WS_CCOLUNA).CD_COLUNA, '>', WS_COUNT_V);
						END IF;

						IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
							FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA ,'<Cell> <Data ss:Type="String">'||FUN.PTG_TRANS(WS_CONTENT)||'</Data></Cell>', '', '');
						END IF;

					END IF;
				END IF;

			WS_BLINK_AUX := '';
			
			--COMENTADO alterado para aplicar o destaque somente na celula e não mais na linha inteira - aplicado agora na NESTED_TD 
			/*IF LENGTH(FUN.CHECK_BLINK_TOTAL(PRM_OBJETO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, RET_COLUNA, '', PRM_SCREEN)) > 7 AND RET_COLTOT = 1 THEN
				WS_BLINK_LINHA := FUN.CHECK_BLINK_TOTAL(PRM_OBJETO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, RET_COLUNA, '', PRM_SCREEN);
			END IF;*/ 

			IF RET_COLGRP = 0 THEN
				IF RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR <> 'SEM' THEN
					WS_BLINK_AUX := FUN.CHECK_BLINK_LINHA(PRM_OBJETO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_LINHA, NVL(RET_COLUNA,'0'), PRM_SCREEN) ; 
				ELSE
					IF RET_COLUNA <> FUN.CDESC(RET_MCOL(WS_CCOLUNA).CD_COLUNA,RET_MCOL(WS_CCOLUNA).CD_LIGACAO) THEN
						WS_BLINK_AUX := FUN.CHECK_BLINK_LINHA(PRM_OBJETO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_LINHA, NVL(RET_COLUNA,'0'), PRM_SCREEN);
					END IF;
				END IF;
				IF LENGTH(WS_BLINK_AUX) > 7 THEN
					WS_BLINK_LINHA := WS_BLINK_AUX;
				END IF;
			END IF;	

			--COMENTADO PARA TESTES APLICADO ACIMA A NOVA CONDIÇÃO PARA APLICAR DESTAQUES
			/*IF RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR <> 'SEM' THEN
				IF LENGTH(FUN.CHECK_BLINK_LINHA(PRM_OBJETO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_LINHA, RET_COLUNA, PRM_SCREEN)) > 7 AND RET_COLGRP = 0 THEN
					WS_BLINK_LINHA := FUN.CHECK_BLINK_LINHA(PRM_OBJETO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_LINHA, RET_COLUNA, PRM_SCREEN);
				END IF;
			ELSE
				IF RET_COLUNA <> FUN.CDESC(RET_MCOL(WS_CCOLUNA).CD_COLUNA,RET_MCOL(WS_CCOLUNA).CD_LIGACAO) THEN
					IF LENGTH(FUN.CHECK_BLINK_LINHA(PRM_OBJETO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_LINHA, RET_COLUNA, PRM_SCREEN)) > 7 AND RET_COLGRP = 0 THEN
						WS_BLINK_LINHA := FUN.CHECK_BLINK_LINHA(PRM_OBJETO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, WS_LINHA, RET_COLUNA, PRM_SCREEN);
					END IF;
				END IF;
			END IF;*/

			
            IF RET_COLTOT = 1 AND RET_MCOL(WS_CCOLUNA).ST_AGRUPADOR <> 'SEM' THEN
				
				IF LENGTH(WS_REPEAT) = 4 THEN
                    
					WS_COUNT_V := 0;
					
					BEGIN
						SELECT COUNT(*) INTO WS_COUNT_V FROM TABLE(FUN.VPIPE((WS_ARR(53)))) WHERE COLUMN_VALUE = RET_MCOL(WS_CCOLUNA).CD_COLUNA;
						IF WS_COUNT_V = 0 THEN
							WS_COUNT := WS_COUNT+1;
							
							BEGIN
								WS_CONTENT_SUM := TO_NUMBER(WS_CONTENT_SUM)+TO_NUMBER(RET_COLUNA);
							EXCEPTION WHEN OTHERS THEN
								WS_CONTENT_SUM := RET_COLUNA;
							END;

							WS_ARRAY_ATUAL(WS_COUNT) := FUN.IFMASCARA(WS_CONTENT_SUM,RTRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA), PRM_VISAO, RET_MCOL(WS_CCOLUNA).CD_COLUNA, PRM_OBJETO, '', RET_MCOL(WS_CCOLUNA).FORMULA, PRM_SCREEN, WS_USUARIO);
							WS_CLASS_ATUAL(WS_COUNT) := WS_JUMP;
						END IF;
					EXCEPTION WHEN OTHERS THEN
						WS_COUNT_V := 0;
					END;
					
				END IF;

			END IF;
			
			WS_JUMP := '';
			WS_CHECK := '';

			WS_COLUNA_ANT(WS_COUNTER)     := RET_COLUNA;
			WS_ARRAY_ANTERIOR(WS_COUNTER) := RET_COLUNA;

			WS_CONTEUDO_A := WS_CONTENT;

		END LOOP;
		
		WS_COUNT := 0;
		WS_CONTENT_SUM := 0;

		IF WS_SAIDA <> 'O' THEN
			IF WS_BLINK_LINHA <> 'N/A' THEN 
			    HTP.P(WS_BLINK_LINHA); 
			END IF;
		END IF;

		WS_BLINK_LINHA := 'N/A';

		WS_FIRSTID := 'N';
		IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
			FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '</Row>', '', '');
		END IF;
		HTP.P('</tr>');
		
		WS_AC_LINHA := 0;
		WS_TOTAL_LINHA := 0;

	END LOOP;

	WS_TOTAL_LINHA := 0;
	WS_AC_LINHA := 0;
	WS_FIXED := 0;

	IF WS_SAIDA <> 'O' AND WS_ARR(52) = 'ROLL' THEN
		IF WS_ARR(49) = 'S' THEN
			WS_BLINK_LINHA := 'N/A';
			HTP.P('<tr class="total duplicado" data-i="0">');

				HTP.P('<td class="fix"></td>');

			    WS_FIXED := NVL(WS_ARR(18), '9999')+1;
				IF LENGTH(WS_ARR(48)) > 0 AND WS_FIXED > 0 THEN
					WS_FIXED := 999;
				END IF;

			    IF WS_FIXED > 1 THEN
					WS_FIX   := 'fix';
					WS_FIXED := WS_FIXED-1;
				ELSE
					WS_FIX   := '';
				END IF;

				WS_COUNTER := 1;
				WS_COUNT   := 0;
				
				LOOP

					IF WS_COUNTER > WS_ARRAY_ATUAL.COUNT THEN
						EXIT;
					END IF;

					IF LENGTH(WS_ARRAY_ATUAL(WS_COUNTER)) > 0 THEN
						WS_COUNT := WS_COUNT+1;
						WS_ARRAY_ATUAL(WS_COUNT) := WS_ARRAY_ATUAL(WS_COUNTER);
						WS_CLASS_ATUAL(WS_COUNT) := WS_CLASS_ATUAL(WS_COUNTER);
					END IF;
					
					WS_COUNTER := WS_COUNTER+1;

				END LOOP;

				HTP.P('<td colspan="'||DIMENSAO_SOMA||'" style="text-align: right;" class="'||WS_FIX||'">'||WS_ARR(50)||'</td>');
				
				FOR T IN 1..WS_INV_TAG LOOP
					HTP.P('<td class="inv"></td>');
				END LOOP;

                WS_COUNTER := 0;
				WS_CONTENT := 0;

				LOOP	
				
					WS_COUNTER := WS_COUNTER+1;
					
					IF WS_COUNTER > WS_COL_VALOR OR WS_COUNTER > WS_COUNT THEN
					    EXIT;
					END IF;
					
					BEGIN
						WS_CONTENT := WS_ARRAY_ATUAL(WS_COUNTER);
					EXCEPTION WHEN OTHERS THEN
						WS_CONTENT := 0;
					END;
					
					BEGIN
						HTP.P('<td '||WS_CLASS_ATUAL(WS_COUNTER)||'>'||WS_CONTENT||'</td>');
					EXCEPTION WHEN OTHERS THEN
						HTP.P('<td>'||SQLERRM||'</td>');
					END;

				END LOOP;

			HTP.P('</tr>');
		END IF;
	END IF;
	
	DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);

	
	IF WS_SAIDA <> 'O' THEN
	    HTP.P('</tbody>');
		
	    HTP.P('</table>');

		IF NVL(WS_ESTILO_LINHA, 'N/A') <> 'N/A' THEN
		    HTP.P('<style>'||WS_ESTILO_LINHA||'</style>');
		END IF;
		
		WS_ESTILO_LINHA := '';
		
	    HTP.P('</div>');
	END IF;
	
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
			IF WS_CCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
				EXIT;
			END IF;
			WS_CCOLUNA := WS_CCOLUNA + 1;
	    END LOOP;

	    IF RET_MCOL(WS_CCOLUNA).CD_LIGACAO <> 'SEM' AND RET_MCOL(WS_CCOLUNA).ST_COM_CODIGO = 'S' THEN
		    WS_TEXTOT := WS_TEXTOT||WS_PIPE||'2';
		    WS_PIPE   := '|';
		    WS_COUNTER := WS_COUNTER + 1;
	    ELSE
		    WS_TEXTOT := WS_TEXTOT||WS_PIPE||'1';
		    WS_PIPE   := '|';
	    END IF;
		
	END LOOP;

	IF WS_SAIDA = 'O' THEN
        SELECT COUNT(*) INTO WS_COUNT FROM USUARIOS WHERE USU_NOME = WS_USUARIO AND NVL(EXCEL_OUT, 'S') = 'S';
		IF WS_COUNT = 1 THEN
			HTP.P('<a style="display: flex; flex-flow: column; align-items: center; margin-top: 20px;" href="dwu.fcl.download_tab?prm_arquivo=spools_'||WS_USUARIO||'.xls&prm_alternativo="><span class="excel" title="'||FUN.LANG('Baixar xml')||'"></span></a>');
		ELSE
			HTP.P('<a style="display: flex; flex-flow: column; align-items: center; margin-top: 20px;"><span class="noexcel" title="'||FUN.LANG('Xml bloqueado')||'"></span></a>');
		END IF;
	END IF;

	HTP.P('</div>');
	IF  PRM_DRILL!='Y' THEN
		HTP.P('</div>');
	END IF;
	
	-- Comentando em 11/02/2022 - estava fechando a div MAIN quando chamado pelo Painel 
	-- HTP.P('</div>');

    IF WS_SAIDA = 'S' OR WS_SAIDA = 'O' THEN
		FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '<Row><Cell><Data ss:Type="String"></Data></Cell></Row>');
		FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '<Row><Cell><Data ss:Type="String">'||FUN.LANG('FILTROS')||': '||FUN.PTG_TRANS(FUN.SHOW_FILTROS(TRIM(WS_PARAMETROS), WS_CURSOR, WS_ISOLADO, PRM_OBJETO, PRM_VISAO, PRM_SCREEN))||'</Data></Cell></Row>');
		FCL.GERA_CONTEUDO(WS_EXCEL, WS_SAIDA, '</Table></Worksheet></Workbook>', '', '');
	END IF;

	SELECT COUNT(*) INTO WS_COUNT FROM USUARIOS WHERE USU_NOME = WS_USUARIO AND NVL(EXCEL_OUT, 'S') = 'S';
	
	IF WS_COUNT = 1 THEN
		DELETE FROM TAB_DOCUMENTOS WHERE NAME = 'spools_'||WS_USUARIO||'.xls' AND USUARIO = WS_USUARIO;
		IF WS_SAIDA <> 'N' AND PRM_DRILL <> 'C' THEN
			BEGIN
				INSERT INTO TAB_DOCUMENTOS VALUES('spools_'||WS_USUARIO||'.xls', 'application/octet', '', 'ascii', SYSDATE, 'BLOB', FUN.C2B(REPLACE(REPLACE(REPLACE(WS_EXCEL, '&', 'E'), '´', ''), '¿', '')), WS_USUARIO);
			EXCEPTION WHEN OTHERS THEN
				HTP.P(SQLERRM);
			END;
		END IF;
	END IF;

	IF PRM_DRILL = 'C' AND NVL(WS_TITULO, 'N/A') = 'N/A' THEN
		HTP.P('<a class="addpurple" onclick="var desc = get(''custom-conteudo-desc'').value; if(desc.length > 3){ call(''save_consulta'', ''prm_visao=''+get(''prm_visao'').title+''&prm_nome='||PRM_OBJETO||'&prm_desc=''+desc+''&prm_coluna=''+get(''prm_coluna_agrup'').title+''&prm_colup=''+get(''prm_coluna_pivot'').title+''&prm_agrupador=''+get(''prm_coluna_valor'').title+''&prm_grupo=&prm_rp=''+get(''prm_coluna_tipo'').title+''&prm_filtros=''+get(''filtropipe'').title).then(function(res){ if(res.indexOf(''#alert'') == -1){ alerta(''feed-fixo'', TR_CR); } }); } else { alerta(''feed-fixo'', TR_DS_LE); }" data-event="false" id="custom-conteudo-submit" style="float: right; margin: 12px 8px 0 0;">MATERIALIZAR CONSULTA</a>');
	END IF;


EXCEPTION 
	WHEN WS_SEMQUERY THEN
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SEMQUERY', WS_USUARIO, 'ERRO');
        COMMIT;
	    HTP.P('<span class="err">Relat&oacute;rio Sem Query</span>');
		HTP.P('</div>');
	WHEN WS_NODATA THEN
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - NODATA', WS_USUARIO, 'ERRO');
        COMMIT;
        IF WS_ADMIN = 'A' THEN
			HTP.P('<span class="errquery">');
				FCL.REPLACE_BINDS(WS_TITLE, WS_BINDS);
			HTP.P('</span>');
		END IF;

		HTP.P('<span class="err">'||NVL(FUN.GETPROP(PRM_OBJETO, 'ERR_SD'), FUN.LANG('Sem Dados'))||'</span>');

		HTP.P('</div>');
		
	WHEN OTHERS	THEN
        INSERT INTO LOG_EVENTOS VALUES(SYSDATE, SUBSTR(PRM_VISAO||'/'||WS_COLUNA||'/'||TRIM(WS_PARAMETROS)||'/'||WS_RP||'/'||WS_COLUP||'/'||WS_AGRUPADOR,1,2000), WS_USUARIO, 'OTHER', 'ERRORLINE', '01');
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - CONSULTA', WS_USUARIO, 'ERRO');
        COMMIT;
		HTP.P('<span class="errorquery">'||SQLERRM||'</span>');
END CONSULTA;

PROCEDURE TITULO  ( PRM_OBJETO  VARCHAR2 DEFAULT NULL,
                    PRM_DRILL   VARCHAR2 DEFAULT NULL,
					PRM_DESC    VARCHAR2 DEFAULT NULL,
					PRM_SCREEN  VARCHAR2 DEFAULT NULL,
					PRM_VALOR   VARCHAR2 DEFAULT NULL,
					PRM_PARAM   VARCHAR2 DEFAULT NULL,
					PRM_USUARIO VARCHAR2 DEFAULT NULL ) AS 

	WS_PROP_TIT_COLOR   VARCHAR2(40);
	WS_PROP_ALIGN_TIT   VARCHAR2(40);
	WS_PROP_TIT_SIZE    VARCHAR2(40);
	WS_PROP_TIT_IT      VARCHAR2(40);
	WS_PROP_TIT_BOLD    VARCHAR2(40);
	WS_PROP_TIT_FONT    VARCHAR2(40);
	WS_PROP_TIT_BGCOLOR VARCHAR2(40);
	WS_PROP_DISPLAY     VARCHAR2(40);
	WS_PROP_COLOR       VARCHAR2(40);
	WS_PROP_DEGRADE     VARCHAR2(40);
	WS_PROP_FONTE_TIT   VARCHAR2(40);
	WS_PROP_FUNDO_TIT   VARCHAR2(40);
	WS_TIPO             VARCHAR2(80);
	WS_SUB              VARCHAR2(200);
	WS_OBJETO           VARCHAR2(200);
	WS_BLINK            VARCHAR2(800);
	WS_PADRAO           VARCHAR2(80) := 'PORTUGUESE';
	ws_aplica_destaque  varchar2(40);
	ws_prop_sub_color	varchar2(80);

	WS_ARR              ARR;


BEGIN
	
	SELECT SUBTITULO, TP_OBJETO INTO WS_SUB, WS_TIPO FROM OBJETOS WHERE CD_OBJETO = PRM_OBJETO;

	WS_PADRAO := GBL.GETLANG;
	
	IF WS_TIPO = 'CONSULTA' THEN
	    
		WS_ARR := FUN.GETPROPS(PRM_OBJETO, WS_TIPO, 'ALIGN_TIT|DEGRADE|FONTE_TIT|FUNDO_TIT|TIT_BOLD', 'DWU');

	    WS_PROP_ALIGN_TIT    := WS_ARR(1);
		WS_PROP_DEGRADE      := WS_ARR(2);
		WS_PROP_FONTE_TIT    := WS_ARR(3);
		WS_PROP_FUNDO_TIT    := WS_ARR(4);
		WS_PROP_TIT_BOLD     := WS_ARR(5);
		
		ws_prop_sub_color 	:= fun.getprop(prm_objeto,'SUB_COLOR');
		WS_PROP_TIT_FONT    := 'color: '||WS_PROP_FONTE_TIT;
		WS_PROP_TIT_BOLD    := 'font-weight: '||WS_PROP_TIT_BOLD;
	    WS_PROP_TIT_BGCOLOR := 'background-color: '||WS_PROP_FUNDO_TIT;
		WS_PROP_ALIGN_TIT   := 'text-align: '||WS_PROP_ALIGN_TIT;

	ELSIF WS_TIPO IN ('PIZZA', 'LINHAS', 'BARRAS', 'COLUNAS', 'MAPA') THEN

	    WS_ARR := FUN.GETPROPS(PRM_OBJETO, WS_TIPO, 'ALIGN_TIT|DEGRADE|TIT_BGCOLOR|TIT_BOLD|TIT_COLOR|TIT_FONT|TIT_IT|TIT_SIZE', 'DWU');

	    WS_PROP_ALIGN_TIT   := WS_ARR(1);
		WS_PROP_DEGRADE     := WS_ARR(2);
		WS_PROP_TIT_BGCOLOR := WS_ARR(3);
		WS_PROP_TIT_BOLD    := WS_ARR(4);
		WS_PROP_TIT_COLOR   := WS_ARR(5);
		WS_PROP_TIT_FONT    := WS_ARR(6);
		WS_PROP_TIT_IT      := WS_ARR(7);
		WS_PROP_TIT_SIZE    := WS_ARR(8);
		
		ws_prop_sub_color 	:= fun.getprop(prm_objeto,'SUB_COLOR');
		WS_PROP_TIT_COLOR   := 'color: '||WS_PROP_TIT_COLOR;
		WS_PROP_TIT_SIZE    := 'font-size: '||WS_PROP_TIT_SIZE;
		WS_PROP_TIT_IT      := 'font-style: '||WS_PROP_TIT_IT;
        WS_PROP_TIT_BOLD    := 'font-weight: '||WS_PROP_TIT_BOLD;
	    WS_PROP_TIT_FONT    := 'font-family: '||WS_PROP_TIT_FONT;
	    WS_PROP_TIT_BGCOLOR := 'background-color: '||WS_PROP_TIT_BGCOLOR;
		WS_PROP_ALIGN_TIT   := 'text-align: '||WS_PROP_ALIGN_TIT;

	ELSIF WS_TIPO = 'VALOR' THEN

		WS_ARR := FUN.GETPROPS(PRM_OBJETO, WS_TIPO, 'ALIGN_TIT|APLICA_DESTAQUE|COLOR|DEGRADE|DISPLAY_TITLE|TIT_BGCOLOR|TIT_BOLD|TIT_COLOR|TIT_FONT|TIT_IT|TIT_SIZE', 'DWU');

	    WS_PROP_ALIGN_TIT   := WS_ARR(1);
		ws_aplica_destaque  := ws_arr(2);
		WS_PROP_COLOR       := WS_ARR(3);
		WS_PROP_DEGRADE     := WS_ARR(4);
		WS_PROP_DISPLAY     := WS_ARR(5);
		WS_PROP_TIT_BGCOLOR := WS_ARR(6);
		WS_PROP_TIT_BOLD    := WS_ARR(7);
		WS_PROP_TIT_COLOR   := WS_ARR(8);
		WS_PROP_TIT_FONT    := WS_ARR(9);
		WS_PROP_TIT_IT      := WS_ARR(10);
		WS_PROP_TIT_SIZE    := WS_ARR(11);
		
		ws_prop_sub_color 	:= fun.getprop(prm_objeto,'SUB_COLOR');
		WS_PROP_TIT_COLOR   := 'color: '||WS_PROP_TIT_COLOR;
		WS_PROP_TIT_SIZE    := 'font-size: '||WS_PROP_TIT_SIZE;
		WS_PROP_TIT_IT      := 'font-style: '||WS_PROP_TIT_IT;
        WS_PROP_TIT_BOLD    := 'font-weight: '||WS_PROP_TIT_BOLD;
	    WS_PROP_TIT_FONT    := 'font-family: '||WS_PROP_TIT_FONT;
	    WS_PROP_TIT_BGCOLOR := 'background-color: '||WS_PROP_TIT_BGCOLOR;
		WS_PROP_DISPLAY     := 'display: '||WS_PROP_DISPLAY;
		WS_PROP_COLOR       := 'color: '||WS_PROP_COLOR;
		WS_PROP_ALIGN_TIT   := 'text-align: '||WS_PROP_ALIGN_TIT;

	ELSIF WS_TIPO = 'RELATORIO' THEN

		HTP.P('');

	ELSE

		WS_ARR := FUN.GETPROPS(PRM_OBJETO, WS_TIPO, 'ALIGN_TIT|COLOR|DEGRADE|TIT_BGCOLOR|TIT_BOLD|TIT_COLOR|TIT_FONT|TIT_IT|TIT_SIZE', 'DWU');

	    WS_PROP_ALIGN_TIT    := WS_ARR(1);
		WS_PROP_COLOR        := WS_ARR(2);
		WS_PROP_DEGRADE      := WS_ARR(3);
		WS_PROP_TIT_BGCOLOR := WS_ARR(4);
		WS_PROP_TIT_BOLD    := WS_ARR(5);
		WS_PROP_TIT_COLOR   := WS_ARR(6);
		WS_PROP_TIT_FONT    := WS_ARR(7);
		WS_PROP_TIT_IT      := WS_ARR(8);
		WS_PROP_TIT_SIZE    := WS_ARR(9);
		
		ws_prop_sub_color 	:= fun.getprop(prm_objeto,'SUB_COLOR');
		WS_PROP_TIT_COLOR   := 'color: '||WS_PROP_TIT_COLOR;
		WS_PROP_TIT_SIZE    := 'font-size: '||WS_PROP_TIT_SIZE;
		WS_PROP_TIT_IT      := 'font-style: '||WS_PROP_TIT_IT;
        WS_PROP_TIT_BOLD    := 'font-weight: '||WS_PROP_TIT_BOLD;
	    WS_PROP_TIT_FONT    := 'font-family: '||WS_PROP_TIT_FONT;
	    WS_PROP_TIT_BGCOLOR := 'background-color: '||WS_PROP_TIT_BGCOLOR;
		WS_PROP_COLOR       := 'color: '||WS_PROP_COLOR;
		WS_PROP_ALIGN_TIT   := 'text-align: '||WS_PROP_ALIGN_TIT;

	END IF;

	if ws_aplica_destaque not in ('titulo','ambos') then 
		ws_blink := 'N/A';
	else    
		WS_BLINK  := FUN.CHECK_BLINK(PRM_OBJETO, SUBSTR(PRM_PARAM, 1 ,INSTR(PRM_PARAM,'|')-1), NVL(PRM_VALOR, 'N/A'), WS_PROP_COLOR, PRM_USUARIO);
	end if; 
	
	IF NVL(WS_BLINK, 'N/A') <> 'N/A' THEN
        WS_BLINK := WS_BLINK||';';
	END IF;

	WS_OBJETO := PRM_OBJETO;

	IF PRM_DRILL = 'Y' THEN
        WS_OBJETO := WS_OBJETO||'trl';
	END IF;
    
	HTP.PRN('<div data-touch="0" class="wd_move drill_'||PRM_DRILL||' degrade_'||WS_PROP_DEGRADE||'" id="'||WS_OBJETO||'_ds">');
		HTP.PRN(''||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', PRM_OBJETO, PRM_DESC, WS_PADRAO), PRM_SCREEN)||'');
	HTP.PRN('</div>');

    
    HTP.PRN('<style> div#'||TRIM(WS_OBJETO)||'_ds { '||WS_PROP_ALIGN_TIT||'; '||WS_PROP_TIT_COLOR||'; '||WS_PROP_TIT_SIZE||'; '||WS_PROP_TIT_IT||'; '||WS_PROP_TIT_BOLD||'; '||WS_PROP_TIT_FONT||'; '||WS_BLINK||' '||WS_PROP_DISPLAY||'; /* verificar necessidade  text-indent: 14px; */ padding: 5px; }
	div#'||TRIM(WS_OBJETO)||'_ds:not(.degrade_S) { '||WS_PROP_TIT_BGCOLOR||'; } </style>');
	
	IF NVL(WS_SUB, 'N/A') <> 'N/A' THEN

        HTP.P('<style>div#'||TRIM(WS_OBJETO)||'_sub { '||WS_PROP_DISPLAY||'; '||WS_PROP_ALIGN_TIT||'; '||WS_PROP_TIT_COLOR||'; '||WS_BLINK||'; color: '||ws_prop_sub_color||'; }</style>');

	    HTP.P('<div class="sub" id="'||WS_OBJETO||'_sub">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', PRM_OBJETO, WS_SUB, WS_PADRAO), PRM_SCREEN)||'</div>');
	
	END IF;

EXCEPTION WHEN OTHERS THEN
    HTP.P(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END TITULO;

PROCEDURE OPCOES ( PRM_OBJETO  VARCHAR2 DEFAULT NULL,
                       PRM_TIPO    VARCHAR2 DEFAULT NULL,
                       PRM_PAR     VARCHAR2 DEFAULT NULL,
					   PRM_VISAO   VARCHAR2 DEFAULT NULL,
					   PRM_SCREEN  VARCHAR2 DEFAULT NULL,
					   PRM_DRILL   VARCHAR2 DEFAULT NULL,
					   PRM_AGRUP   VARCHAR2 DEFAULT NULL,
					   PRM_COLUP   VARCHAR2 DEFAULT NULL,
					   PRM_USUARIO VARCHAR2 DEFAULT NULL ) AS

    WS_COUNT        NUMBER;
	WS_DRILL        BOOLEAN := FALSE;
	WS_FILTER       BOOLEAN := FALSE;
	WS_ATTRIB       BOOLEAN := FALSE;
	WS_ITENS        NUMBER  := 0;
	WS_TPT          VARCHAR2(400);
	WS_ADMIN        VARCHAR2(80);
	WS_USUARIO      VARCHAR2(80);
	WS_TEMPO_QUERY  NUMBER  := 0;
	WS_TEMPO_AVG    NUMBER  := 0;
	WS_QUERY_HINT   VARCHAR2(80);
	WS_NOME         VARCHAR2(200);
	WS_OBS			VARCHAR2(4000);
	WS_COUNT_FILTRO   NUMBER;
	WS_COUNT_DESTAQUE NUMBER;
    
BEGIN

	IF NVL(PRM_USUARIO, 'N/A') = 'N/A' THEN
        WS_USUARIO := GBL.GETUSUARIO;
	ELSE
		WS_USUARIO := PRM_USUARIO;
	END IF;

	WS_ADMIN   := GBL.GETNIVEL;

	IF FUN.GETPROP(PRM_OBJETO, 'QUERY_STAT') = 'S' THEN
        BEGIN
			SELECT DISTINCT FIRST_VALUE(TEMPO) OVER (ORDER BY DT_STAT DESC) INTO WS_TEMPO_QUERY FROM QUERY_STAT WHERE TRIM(CD_OBJETO) = TRIM(PRM_OBJETO);		
			IF NVL(WS_TEMPO_QUERY, 999) <> 999 THEN
				SELECT ROUND(AVG(TEMPO)) INTO WS_TEMPO_AVG FROM QUERY_STAT WHERE CD_OBJETO = PRM_OBJETO AND TO_CHAR(DT_STAT, 'DD/MM/YY') = TO_CHAR(SYSDATE, 'DD/MM/YY');
				WS_QUERY_HINT := 'Tempo da &uacute;ltima recarga: '||WS_TEMPO_QUERY||'ms &#10;Tempo m&eacute;dio de hoje: '||WS_TEMPO_AVG||'ms';
			END IF;
		EXCEPTION WHEN OTHERS THEN
			WS_QUERY_HINT := '';
		END;
	END IF;

	SELECT NM_OBJETO, FUN.SUBPAR(DS_OBJETO, PRM_SCREEN) INTO WS_NOME, WS_OBS FROM OBJETOS WHERE CD_OBJETO = REPLACE(PRM_OBJETO, 'trl', '');

	IF NVL(WS_ADMIN, 'N') <> 'A' THEN
        
		IF FUN.CHECK_ADMIN('DRILLS_ADD') AND FUN.CHECK_ADMIN('DRILLS_EX') THEN
            WS_DRILL := TRUE;
		ELSE
            WS_DRILL := FALSE;
		END IF;
	    
		IF FUN.CHECK_ADMIN('FILTERS_ADD') AND FUN.CHECK_ADMIN('FILTERS_EX') THEN
            WS_FILTER := TRUE;
		ELSE
            WS_FILTER := FALSE;
		END IF;
	    
		WS_ATTRIB := FUN.CHECK_ADMIN('ATTRIB_ALT');
		
	END IF;

    CASE

	    WHEN PRM_TIPO = 'CONSULTA' THEN

		    



			
			IF NVL(WS_OBS, 'N/A') <> 'N/A' THEN
				HTP.P('<span class="obs" data-obs="<h4>'||FUN.LANG('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||WS_OBS||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">&#63;</span>');
			END IF;
			
			IF WS_ADMIN = 'A' THEN
				
				HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||PRM_OBJETO||'more">');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'atrib', PRM_SCREEN));
					
					HTP.P('<span class="preferencias" data-visao="'||PRM_VISAO||'" data-drill="'||PRM_DRILL||'" title="'||FUN.LANG('Propriedades')||'"></span>');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'filter', PRM_VISAO));
					HTP.P('<span class="sigma" title="'||FUN.LANG('Linha calculada')||'"></span>');
					HTP.P('<span class="lightbulb" title="'||FUN.LANG('Drill')||'"></span>');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO||'c', 'excel'));
					HTP.P('<span class="data_table" title="'||FUN.LANG('Alterar Consulta')||'"></span>');
					HTP.P(FUN.SHOWTAG('', 'star'));
					
					IF PRM_DRILL = 'Y' THEN
						HTP.P('<span title="'||FUN.LANG('Marcar objeto')||'" style="position: relative; height: 26px; width: 20px; float: left; text-align: center; line-height: 32px;" onclick="loading(); ajax(''fly'', ''favoritar'', ''prm_objeto='||PRM_OBJETO||'&prm_nome=''+document.getElementById('''||PRM_OBJETO||'_ds'').innerHTML+''&prm_url=&prm_screen=''+document.getElementById(''current_screen'').value+''&prm_parametros=''+encodeURIComponent(document.getElementById(''par_'||PRM_OBJETO||''').value)+''&prm_dimensao=''+encodeURIComponent(document.getElementById(''col_'||PRM_OBJETO||''').value)+''&prm_medida=''+encodeURIComponent(document.getElementById(''agp_'||PRM_OBJETO||''').value)+''&prm_pivot=''+encodeURIComponent(document.getElementById(''cup_'||PRM_OBJETO||''').value)+''&prm_acao=incluir'', false); loading(); call(''obj_screen_count'', ''prm_screen=''+tela+''&prm_tipo=FAVORITOS'').then(function(resposta){ if(parseInt(resposta) > 0){ document.getElementById(''favoritos'').classList.remove(''inv''); } else { document.getElementById(''favoritos'').classList.add(''inv''); } });">');
							HTP.P('<svg style="height: 16px; width: 16px;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 width="613.408px" height="613.408px" viewBox="0 0 613.408 613.408" style="enable-background:new 0 0 613.408 613.408;" 	 xml:space="preserve"> <g> 	<path d="M605.254,168.94L443.792,7.457c-6.924-6.882-17.102-9.239-26.319-6.069c-9.177,3.128-15.809,11.241-17.019,20.855 		l-9.093,70.512L267.585,216.428h-142.65c-10.344,0-19.625,6.215-23.629,15.746c-3.92,9.573-1.71,20.522,5.589,27.779 		l105.424,105.403L0.699,613.408l246.635-212.869l105.423,105.402c4.881,4.881,11.45,7.467,17.999,7.467 		c3.295,0,6.632-0.709,9.78-2.002c9.573-3.922,15.726-13.244,15.726-23.504V345.168l123.839-123.714l70.429-9.176 		c9.614-1.251,17.727-7.862,20.813-17.039C614.472,186.021,612.136,175.801,605.254,168.94z M504.856,171.985 		c-5.568,0.751-10.762,3.232-14.745,7.237L352.758,316.596c-4.796,4.775-7.466,11.242-7.466,18.041v91.742L186.437,267.481h91.68 		c6.757,0,13.243-2.669,18.04-7.466L433.51,122.766c3.983-3.983,6.569-9.176,7.258-14.786l3.629-27.696l88.155,88.114 		L504.856,171.985z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');              
						HTP.P('</span>');
					ELSE
                        HTP.P(FUN.SHOWTAG('', 'remove'));
					END IF;
					
				HTP.P('</span>');

	        ELSE
		        
				IF FUN.GETPROP(PRM_OBJETO,'NO_OPTION') <> 'S' THEN

					SELECT COUNT(*) INTO WS_COUNT FROM PONTO_AVALIACAO WHERE CS_AGRUPADOR IN (SELECT NVL(CD_COLUNA, 'N/A') FROM MICRO_COLUNA WHERE ST_AGRUPADOR = 'TPT' AND CD_MICRO_VISAO = PRM_VISAO) AND CD_PONTO = PRM_OBJETO;

					IF WS_COUNT > 0 THEN
						SELECT NVL(CS_AGRUPADOR, 'N/A') INTO WS_TPT FROM PONTO_AVALIACAO WHERE CS_AGRUPADOR IN (SELECT NVL(CD_COLUNA, 'N/A') FROM MICRO_COLUNA WHERE ST_AGRUPADOR = 'TPT' AND CD_MICRO_VISAO = PRM_VISAO) AND CD_PONTO = PRM_OBJETO;
					ELSE
						WS_TPT := 'N/A';
					END IF;

					IF WS_TPT <> 'N/A' THEN
						HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||PRM_OBJETO||'more" style="max-width: 98px; max-height: 64px;">');
					ELSE
						HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||PRM_OBJETO||'more" style="max-width: 126px; max-height: 64px;">');
					END IF;
						HTP.P('<span class="lightbulb" title="'||FUN.LANG('Drill')||'"></span>');
						
						HTP.P(FUN.SHOWTAG(PRM_OBJETO||'c', 'excel'));
					IF WS_TPT <> 'N/A' THEN
						HTP.P('<span class="data_table" title="'||FUN.LANG('Alterar Template')||'" onclick=" fakeOption('''||WS_TPT||''', ''Op&ccedil;&otilde;es do template'', ''template'', '''||PRM_VISAO||''');"></span>');
					END IF;
					HTP.P('<span title="'||FUN.LANG('Marcar objeto')||'" style="position: relative; height: 26px; width: 20px; float: left; text-align: center; line-height: 32px;" onclick="loading(); ajax(''fly'', ''favoritar'', ''prm_objeto='||PRM_OBJETO||'&prm_nome=''+document.getElementById('''||PRM_OBJETO||'_ds'').innerHTML+''&prm_url=&prm_screen=''+document.getElementById(''current_screen'').value+''&prm_parametros=''+encodeURIComponent(document.getElementById(''par_'||PRM_OBJETO||''').value)+''&prm_dimensao=''+encodeURIComponent(document.getElementById(''col_'||PRM_OBJETO||''').value)+''&prm_medida=''+encodeURIComponent(document.getElementById(''agp_'||PRM_OBJETO||''').value)+''&prm_pivot=''+encodeURIComponent(document.getElementById(''cup_'||PRM_OBJETO||''').value)+''&prm_acao=incluir'', false); loading(); call(''obj_screen_count'', ''prm_screen=''+tela+''&prm_tipo=FAVORITOS'').then(function(resposta){ if(parseInt(resposta) > 0){ document.getElementById(''favoritos'').classList.remove(''inv''); } else { document.getElementById(''favoritos'').classList.add(''inv''); } });">');
						HTP.P('<svg style="height: 16px; width: 16px;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 width="613.408px" height="613.408px" viewBox="0 0 613.408 613.408" style="enable-background:new 0 0 613.408 613.408;" 	 xml:space="preserve"> <g> 	<path d="M605.254,168.94L443.792,7.457c-6.924-6.882-17.102-9.239-26.319-6.069c-9.177,3.128-15.809,11.241-17.019,20.855 		l-9.093,70.512L267.585,216.428h-142.65c-10.344,0-19.625,6.215-23.629,15.746c-3.92,9.573-1.71,20.522,5.589,27.779 		l105.424,105.403L0.699,613.408l246.635-212.869l105.423,105.402c4.881,4.881,11.45,7.467,17.999,7.467 		c3.295,0,6.632-0.709,9.78-2.002c9.573-3.922,15.726-13.244,15.726-23.504V345.168l123.839-123.714l70.429-9.176 		c9.614-1.251,17.727-7.862,20.813-17.039C614.472,186.021,612.136,175.801,605.254,168.94z M504.856,171.985 		c-5.568,0.751-10.762,3.232-14.745,7.237L352.758,316.596c-4.796,4.775-7.466,11.242-7.466,18.041v91.742L186.437,267.481h91.68 		c6.757,0,13.243-2.669,18.04-7.466L433.51,122.766c3.983-3.983,6.569-9.176,7.258-14.786l3.629-27.696l88.155,88.114 		L504.856,171.985z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');              
					HTP.P('</span>');
					HTP.P(FUN.SHOWTAG('', 'star'));
					HTP.P('</span>');
				END IF;

	    	END IF;

		WHEN PRM_TIPO = 'VALOR' THEN
		    IF INSTR(PRM_OBJETO, 'trl') = 0 AND INSTR(PRM_OBJETO, 'temp') = 0 THEN
			    HTP.P('<span id="'||PRM_OBJETO||'sync" class="sync" title="'||WS_QUERY_HINT||'"><img src="dwu.fcl.download?arquivo=sinchronize.png" /></span>');
			END IF;
			
			IF WS_ADMIN = 'A' THEN
				HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||PRM_OBJETO||'more" >');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'atrib', PRM_SCREEN));
					
					HTP.P('<span class="preferencias" alt="P" title="'||FUN.LANG('Propriedades')||'"></span>');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'filter', PRM_VISAO));
					HTP.P('<span class="lightbulb" title="'||FUN.LANG('Drills')||'"></span>');
					HTP.P('<span class="star" title="'||FUN.LANG('Alterar Destaque')||'" ></span>');
                    
					FCL.BUTTON_LIXO('dl_obj', PRM_OBJETO=> PRM_OBJETO, PRM_TAG => 'span');
				HTP.P('</span>');
				
			ELSE
				IF FUN.GETPROP(REPLACE(PRM_OBJETO, 'trl', ''),'NO_OPTION') <> 'S' THEN
				    HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||PRM_OBJETO||'more">');
					
					
					
					
					

						IF WS_FILTER THEN
						    HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'filter', PRM_VISAO));
							WS_ITENS := WS_ITENS+1;
						END IF;
						
						IF WS_DRILL THEN
						    HTP.P('<span class="lightbulb" title="'||FUN.LANG('Drills')||'"></span>');
							WS_ITENS := WS_ITENS+1;
						END IF;

						
						
					HTP.P('</span>');
					WS_ITENS := 34*WS_ITENS;
				    IF WS_ITENS = 0 THEN
					    HTP.P('<style>div#'||PRM_OBJETO||' span.options { display: none; } div#'||PRM_OBJETO||' span.turn { right: 3px; }</style>');
					ELSE
					    HTP.P('<style>div#'||PRM_OBJETO||' span.options { max-width: '||WS_ITENS||'px; max-height: 33px; }</style>');
					END IF;
				END IF;

				IF PRM_DRILL = 'Y' OR INSTR(PRM_OBJETO, 'temp') <> 0 THEN
					HTP.P('<a class="fechar" id="'||PRM_OBJETO||'fechar" title="'||FUN.LANG('Fechar')||'"></a>');
				END IF;

			END IF;

			WS_COUNT_FILTRO   := LENGTH(TRIM(FUN.SHOW_FILTROS(PRM_PAR, '', '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN)));
			WS_COUNT_DESTAQUE := LENGTH(TRIM(FUN.SHOW_DESTAQUES(PRM_PAR, '', '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN)));
			
			IF WS_COUNT_FILTRO > 3 OR WS_COUNT_DESTAQUE > 3 OR NVL(WS_OBS, 'N/A') <> 'N/A' THEN
				HTP.P('<span class="turn">');
					
					IF NVL(WS_OBS, 'N/A') <> 'N/A' THEN
						HTP.P('<span class="obs" data-obs="<h4>'||FUN.LANG('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||WS_OBS||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">&#63;</span>');
					END IF;
					
					IF WS_COUNT_FILTRO > 3 THEN
						HTP.P('<span class="filtros">F</span>');
					END IF;

					IF WS_COUNT_DESTAQUE > 3 THEN
						HTP.P('<span class="destaques">');
						HTP.P('</span>');
					END IF;
				HTP.P('</span>'); 
			END IF;

		WHEN PRM_TIPO = 'PONTEIRO' THEN
		    IF INSTR(PRM_OBJETO, 'trl') = 0 AND INSTR(PRM_OBJETO, 'temp') = 0 THEN
			    HTP.P('<span id="'||PRM_OBJETO||'sync" class="sync" title="'||WS_QUERY_HINT||'"><img src="dwu.fcl.download?arquivo=sinchronize.png" /></span>');
		    END IF;
			
			
			
			IF WS_ADMIN = 'A' THEN
				HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||PRM_OBJETO||'more" >');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'atrib', PRM_SCREEN));
					HTP.P('<span class="preferencias" title="'||FUN.LANG('Propriedades')||'"></span>');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'filter', PRM_VISAO));
					HTP.P('<span class="lightbulb" title="'||FUN.LANG('Drills')||'"></span>');
					FCL.BUTTON_LIXO('dl_obj', PRM_OBJETO=> PRM_OBJETO, PRM_TAG => 'span');
				HTP.P('</span>');
			ELSE
				

				IF PRM_DRILL = 'Y' OR INSTR(PRM_OBJETO, 'temp') <> 0 THEN
					HTP.P('<a class="fechar" id="'||PRM_OBJETO||'fechar" title="'||FUN.LANG('Fechar')||'"></a>');
				END IF;
			END IF;


			IF LENGTH(TRIM(FUN.SHOW_FILTROS(PRM_PAR, '', '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN))) > 3 OR NVL(WS_OBS, 'N/A') <> 'N/A' THEN
				HTP.P('<span class="turn">');
					IF NVL(WS_OBS, 'N/A') <> 'N/A' THEN
						HTP.P('<span class="obs" data-obs="<h4>'||FUN.LANG('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||WS_OBS||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">&#63;</span>');
					END IF;
					HTP.P('<span class="filtros">F</span>');
				HTP.P('</span>');
			END IF;


		WHEN PRM_TIPO IN ('LINHAS','BARRAS','PIZZA', 'COLUNAS') THEN
		
		    IF INSTR(PRM_OBJETO, 'trl') = 0 AND INSTR(PRM_OBJETO, 'temp') = 0 THEN
			    HTP.P('<span id="'||PRM_OBJETO||'sync" class="sync" title="'||WS_QUERY_HINT||'"><img src="dwu.fcl.download?arquivo=sinchronize.png" /></span>');
			ELSE
                HTP.P('<a class="fechar" id="'||PRM_OBJETO||'fechar" title="'||FUN.LANG('Fechar')||'">');
					HTP.P('<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="612px" height="612px" viewBox="0 0 612 612" style="enable-background:new 0 0 612 612;" xml:space="preserve"> <g> 	<g id="cross"> 		<g> 			<polygon points="612,36.004 576.521,0.603 306,270.608 35.478,0.603 0,36.004 270.522,306.011 0,575.997 35.478,611.397 				306,341.411 576.521,611.397 612,575.997 341.459,306.011 			"></polygon> 		</g> 	</g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
				HTP.P('</a>');
			END IF;

			WS_ITENS := 0;
			
			IF WS_ADMIN = 'A' THEN

				HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||PRM_OBJETO||'more">');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'atrib', PRM_SCREEN));
					HTP.P('<span class="preferencias" title="'||FUN.LANG('Propriedades')||'"></span>');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'filter', PRM_VISAO));
					HTP.P('<span class="lightbulb" title="'||FUN.LANG('Drills')||'"></span>');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'star', 'png'));
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'export', 'png'));
					
					IF INSTR(PRM_OBJETO, 'trl') = 0 THEN
					    FCL.BUTTON_LIXO('dl_obj', PRM_OBJETO=> PRM_OBJETO, PRM_TAG => 'span');
					END IF;
				HTP.P('</span>');

			ELSE

				IF FUN.GETPROP(REPLACE(PRM_OBJETO, 'trl', ''),'NO_OPTION') <> 'S' THEN
				    IF PRM_DRILL = 'Y' OR INSTR(PRM_OBJETO, 'temp') > 0 THEN
					    HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||PRM_OBJETO||'more">');
					ELSE
					    HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||PRM_OBJETO||'more">');
					END IF;	
						
						IF WS_FILTER THEN
						    HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'filter', PRM_VISAO));
							WS_ITENS := WS_ITENS+1;
						END IF;

						IF WS_DRILL THEN
						    HTP.P('<span class="lightbulb" title="'||FUN.LANG('Drills')||'"></span>');
							WS_ITENS := WS_ITENS+1;
						END IF;

						HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'export', 'png'));
						WS_ITENS := WS_ITENS+1;
					HTP.P('</span>');
				END IF;

				WS_ITENS := 34*WS_ITENS;
				HTP.P('<style>div#'||PRM_OBJETO||' span.options { max-width: '||WS_ITENS||'px; max-height: 33px; }</style>');

				IF PRM_DRILL = 'Y' OR INSTR(PRM_OBJETO, 'temp') <> 0 THEN
					HTP.P('<a class="fechar" id="'||PRM_OBJETO||'fechar" title="'||FUN.LANG('Fechar')||'"></a>');
				END IF;
			END IF;

			IF LENGTH(TRIM(FUN.SHOW_FILTROS(PRM_PAR, '', '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN))) > 3 OR LENGTH(TRIM(FUN.SHOW_DESTAQUES(PRM_PAR, '', '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN))) > 3 OR NVL(WS_OBS, 'N/A') <> 'N/A' THEN
				HTP.P('<span class="turn">');

					IF NVL(WS_OBS, 'N/A') <> 'N/A' THEN
						HTP.P('<span class="obs" data-obs="<h4>'||FUN.LANG('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||WS_OBS||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">&#63;</span>');
					END IF;
					
					IF LENGTH(TRIM(FUN.SHOW_FILTROS(PRM_PAR, '', '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN))) > 3 THEN
						HTP.P('<span class="filtros">F</span>');
					END IF;

					IF LENGTH(TRIM(FUN.SHOW_DESTAQUES(PRM_PAR, '', '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN))) > 3 THEN
						HTP.P('<span class="destaques">');
							
						HTP.P('</span>');
					END IF;

				HTP.P('</span>');
			END IF;

		WHEN PRM_TIPO = 'ICONE' THEN
		    
			IF WS_ADMIN = 'A' THEN
				HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||TRIM(PRM_OBJETO)||'more">');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'atrib', PRM_SCREEN));
					HTP.P('<span class="preferencias" title="'||FUN.LANG('Propriedades')||'"></span>');
					
					FCL.BUTTON_LIXO('dl_obj', PRM_OBJETO=> PRM_OBJETO, PRM_TAG => 'span');
				HTP.P('</span>');
				
			END IF;

		WHEN PRM_TIPO = 'IMAGE' THEN
		    
			IF WS_ADMIN = 'A' THEN
				HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options bolota closed" id="'||TRIM(PRM_OBJETO)||'more">');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'atrib', PRM_SCREEN));
					HTP.P('<span class="preferencias" title="'||FUN.LANG('Propriedades')||'"></span>');
					FCL.BUTTON_LIXO('dl_obj', PRM_OBJETO=> PRM_OBJETO, PRM_TAG => 'span');
					
				HTP.P('</span>');
				
			END IF;

		WHEN PRM_TIPO = 'RELATORIO' THEN
		    
			IF NVL(WS_OBS, 'N/A') <> 'N/A' THEN
				HTP.P('<span class="obs" data-obs="<h4>'||FUN.LANG('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||WS_OBS||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">&#63;</span>');
			END IF;
			
			IF WS_ADMIN = 'A' THEN
				HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options bolota closed" id="'||TRIM(PRM_OBJETO)||'more">');
					HTP.P('<span class="preferencias" title="'||FUN.LANG('Propriedades')||'"></span>');
					FCL.BUTTON_LIXO('dl_obj', PRM_OBJETO=> PRM_OBJETO, PRM_TAG => 'span');
					
				HTP.P('</span>');

                

			END IF;


			IF PRM_DRILL = 'Y' OR INSTR(WS_NOME, 'temp') > 0 THEN

				HTP.P('<a class="fechar" id="'||PRM_OBJETO||'fechar" title="'||FUN.LANG('Fechar')||'"></a>');
				
			END IF;
			
		WHEN PRM_TIPO = 'FILE' THEN
		    IF WS_ADMIN = 'A' THEN
				HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||TRIM(PRM_OBJETO)||'more">');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'atrib', PRM_SCREEN));
					HTP.P('<span class="preferencias" title="'||FUN.LANG('Propriedades')||'"></span>');
					FCL.BUTTON_LIXO('dl_obj', PRM_OBJETO=> PRM_OBJETO, PRM_TAG => 'span');
					
				HTP.P('</span>');
			END IF;
			
		WHEN PRM_TIPO = 'TEXTO' THEN
		    IF  WS_ADMIN = 'A' THEN
				HTP.P('<span id="'||RTRIM(PRM_OBJETO)||'more" class="options closed">');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'atrib', PRM_SCREEN));
					HTP.P('<span class="preferencias" title="'||FUN.LANG('Propriedades')||'"></span>');
					FCL.BUTTON_LIXO('dl_obj', PRM_OBJETO=> PRM_OBJETO, PRM_TAG => 'span');
					
				HTP.P('</span>');
				
				HTP.P('<span id="'||PRM_OBJETO||'_ds" class="wd_move" style="text-align: left; position: relative; margin: -12px 20px 0 0; letter-spacing: -2px; font-size: 12px;">===</span>');

			END IF;
		WHEN PRM_TIPO = 'GENERICO' THEN

		    HTP.P('<span id="'||PRM_OBJETO||'sync" class="sync"><img src="dwu.fcl.download?arquivo=sinchronize.png" /></span>');

			IF  WS_ADMIN = 'A' THEN
				HTP.P('<span id="'||RTRIM(PRM_OBJETO)||'more" class="options closed" style="max-width: 70px;">');
					
					HTP.P('<span class="preferencias" title="'||FUN.LANG('Propriedades')||'"></span>');
					FCL.BUTTON_LIXO('dl_obj', PRM_OBJETO=> PRM_OBJETO, PRM_TAG => 'span');
					
				HTP.P('</span>');

			END IF;
		
		WHEN PRM_TIPO = 'MAPA' THEN
            
			IF INSTR(PRM_OBJETO, 'trl') = 0 AND INSTR(WS_NOME, 'temp') = 0 THEN
			    HTP.P('<span id="'||PRM_OBJETO||'sync" class="sync" title="'||WS_QUERY_HINT||'"><img src="dwu.fcl.download?arquivo=sinchronize.png" /></span>');
            ELSE
                HTP.P('<a class="fechar" id="'||PRM_OBJETO||'fechar" title="'||FUN.LANG('Fechar')||'">');
					HTP.P('<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="612px" height="612px" viewBox="0 0 612 612" style="enable-background:new 0 0 612 612;" xml:space="preserve"> <g> 	<g id="cross"> 		<g> 			<polygon points="612,36.004 576.521,0.603 306,270.608 35.478,0.603 0,36.004 270.522,306.011 0,575.997 35.478,611.397 				306,341.411 576.521,611.397 612,575.997 341.459,306.011 			"></polygon> 		</g> 	</g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
				HTP.P('</a>');
			END IF;

			IF LENGTH(TRIM(FUN.SHOW_FILTROS(PRM_PAR, '', '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN))) > 3 THEN
				HTP.P('<span class="turn">');
					IF NVL(WS_OBS, 'N/A') <> 'N/A' THEN
						HTP.P('<span class="obs" data-obs="<h4>'||FUN.LANG('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||WS_OBS||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">&#63;</span>');
					END IF;
					HTP.P('<span class="filtros">F</span>');
				HTP.P('</span>');
			END IF;
			
		    IF WS_ADMIN = 'A' THEN
				
				HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" style="max-width: 142px;" id="'||PRM_OBJETO||'more">');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'atrib', PRM_SCREEN));
					
					HTP.P('<span class="preferencias" title="'||FUN.LANG('Propriedades')||'"></span>');
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'filter', PRM_VISAO));
					HTP.P('<span class="lightbulb" title="Drills"></span>');
					
					HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'export', 'png'));
					IF INSTR(PRM_OBJETO, 'trl') = 0 THEN
					    FCL.BUTTON_LIXO('dl_obj', PRM_OBJETO=> PRM_OBJETO, PRM_TAG => 'span');
					END IF;
				HTP.P('</span>');
				
			ELSE

				IF FUN.GETPROP(REPLACE(PRM_OBJETO, 'trl', ''),'NO_OPTION') <> 'S' THEN
				        
					HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" style="max-height: 33px;" id="'||PRM_OBJETO||'more">');
					    
						IF WS_FILTER THEN
						    HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'filter', PRM_VISAO));
						END IF;
						
						IF WS_DRILL THEN
						    HTP.P('<span class="lightbulb" title="'||FUN.LANG('Drills')||'"></span>');
						END IF;

						HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'export', 'png'));
					HTP.P('</span>');
				END IF;

				IF PRM_DRILL = 'Y' OR INSTR(WS_NOME, 'temp') > 0 THEN
					HTP.P('<a class="fechar" id="'||PRM_OBJETO||'fechar" title="'||FUN.LANG('Fechar')||'"></a>');
				END IF;
				
			END IF;
			
		WHEN PRM_TIPO = 'HEATMAP' THEN

		    IF WS_ADMIN = 'A' THEN
				
				HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="closed" style="max-width: 104px;" id="'||PRM_OBJETO||'more">');	
				HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'atrib', PRM_SCREEN));
				HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'filter', PRM_VISAO));

			ELSE
			    
				HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="closed" style="max-width: 50px;" id="'||PRM_OBJETO||'more">');

			END IF;
			
			HTP.P('<span id="'||PRM_OBJETO||'_center" title="'||FUN.LANG('Centralizar')||'" class="center" onclick="var centro = document.getElementById('''||PRM_OBJETO||''').getAttribute(''data-center''); call(''alter_attrib'', ''prm_objeto='||PRM_OBJETO||'&prm_prop=CENTER&prm_value=''+centro+''&prm_usuario='||WS_USUARIO||''').then(function(resposta){ if(resposta.indexOf(''error'') != -1 || resposta.indexOf(''FAIL'') != -1){ alerta(''feed-fixo'', TR_ER); } else { alerta(''feed-fixo'', '''||FUN.LANG('Centralizado no ponto atual')||'''); } });"><svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 width="79.536px" height="79.536px" viewBox="0 0 79.536 79.536" style="enable-background:new 0 0 79.536 79.536;" 	 xml:space="preserve"> <g> 	<path style="fill:#010002;" d="M48.416,39.763c0,4.784-3.863,8.647-8.627,8.647c-4.782,0-8.647-3.863-8.647-8.647 		c0-4.771,3.865-8.627,8.647-8.627C44.553,31.136,48.416,34.992,48.416,39.763z M43.496,79.531V66.088l3.998-0.01l-7.716-13.35 		l-7.72,13.359h3.992v13.442H43.496z M0,43.481h13.463v4.008l13.362-7.715l-13.367-7.726l0.005,3.998H0.005L0,43.481z 		 M79.536,36.045H66.089v-3.987l-13.365,7.715l13.365,7.706v-3.988l13.447-0.01V36.045z M36.056,0.005v13.442l-3.998,0.011 		l7.72,13.362l7.716-13.362h-3.998V0.005H36.056z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg></span>');
			HTP.P('<span style="border-radius: 10px;" id="'||PRM_OBJETO||'_zoom" title="'||FUN.LANG('Zoom')||'" class="zoom" onclick="var zoom = document.getElementById('''||PRM_OBJETO||''').getAttribute(''data-zoom''); call(''alter_attrib'', ''prm_objeto='||PRM_OBJETO||'&prm_prop=ZOOM&prm_value=''+zoom+''&prm_usuario='||WS_USUARIO||''').then(function(resposta){ if(resposta.indexOf(''error'') != -1 || resposta.indexOf(''FAIL'') != -1){ alerta(''feed-fixo'', TR_ER); } else { alerta(''feed-fixo'', '''||FUN.LANG('Zoom fixado para o valor atual')||'''); } });"><svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 viewBox="0 0 206.166 206.166" style="enable-background:new 0 0 206.166 206.166;" xml:space="preserve"> <g> 	<g> 		<g> 			<path d="M176.009,30.157c-40.209-40.209-105.643-40.209-145.852,0c-40.209,40.211-40.209,105.639,0,145.852 				c20.105,20.105,46.516,30.157,72.926,30.157s52.822-10.052,72.926-30.157C216.218,135.797,216.218,70.368,176.009,30.157z 				 M35.766,35.766C54.324,17.207,78.706,7.93,103.083,7.93c23.145,0,46.291,8.363,64.454,25.09L33.019,167.537 				C-1.325,130.238-0.411,71.944,35.766,35.766z M170.4,170.4c-36.18,36.176-94.48,37.091-131.771,2.747L173.146,38.629 				C207.49,75.927,206.576,134.22,170.4,170.4z"/> 			<path d="M91.384,59.732H75.316V43.583c0-2.19-1.774-3.967-3.967-3.967s-3.967,1.776-3.967,3.967v16.149H51.718 				c-2.192,0-3.967,1.776-3.967,3.967c0,2.191,1.774,3.967,3.966,3.967h15.665V83.25c0,2.19,1.774,3.967,3.967,3.967 				s3.967-1.776,3.967-3.967V67.666h16.068c2.192,0,3.967-1.776,3.967-3.967C95.351,61.509,93.577,59.732,91.384,59.732z"/> 			<path d="M154.649,134.816h-39.667c-2.192,0-3.967,1.774-3.967,3.967s1.774,3.967,3.967,3.967h39.667 				c2.192,0,3.967-1.774,3.967-3.967S156.842,134.816,154.649,134.816z"/> 		</g> 	</g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg></span>');
				
			HTP.P('</span>');
			HTP.P('<a class="fechar" id="'||PRM_OBJETO||'fechar" title="'||FUN.LANG('Fechar')||'">X</a>');
			
			HTP.P('<span class="turn">');

				IF LENGTH(TRIM(FUN.SHOW_FILTROS(PRM_PAR, '', '', PRM_OBJETO, PRM_VISAO, PRM_SCREEN))) > 3 THEN
					HTP.P('<span class="filtros">F</span>');
				END IF;

			HTP.P('</span>');
		ELSE
		    HTP.P('<a class="fechar" id="'||PRM_OBJETO||'fechar" title="'||FUN.LANG('Fechar')||'">X</a>');
	END CASE;

END OPCOES;

PROCEDURE SHOW_OBJETO ( PRM_OBJETO      VARCHAR2 DEFAULT NULL,
						PRM_POSX	    VARCHAR2 DEFAULT NULL,
						PRM_POSY	    VARCHAR2 DEFAULT NULL,
						PRM_PARAMETROS  CLOB     DEFAULT NULL,
						PRM_DRILL	    VARCHAR2 DEFAULT 'N',
						PRM_OUT		    VARCHAR2 DEFAULT 'N',
						PRM_ZINDEX	    VARCHAR2 DEFAULT '2',
						PRM_SCREEN      VARCHAR2 DEFAULT NULL,
						PRM_FORCET      VARCHAR2 DEFAULT NULL,
						PRM_TRACK       VARCHAR2 DEFAULT NULL,
						PRM_OBJETON     VARCHAR2 DEFAULT NULL,
						PRM_ALT_MED     VARCHAR2 DEFAULT 'no_change',
						PRM_CROSS       CHAR     DEFAULT 'T',
						PRM_SELF        VARCHAR2 DEFAULT NULL,
						PRM_DASHBOARD   VARCHAR2 DEFAULT 'false',
						PRM_USUARIO     VARCHAR2 DEFAULT NULL,
						PRM_ADMIN       VARCHAR2 DEFAULT NULL  ) AS

	WS_MASCARA		    VARCHAR2(30);
	WS_UNIDADE		    VARCHAR2(30);
	WS_GOTO             VARCHAR2(2000);

	WS_CD_PONTO		    VARCHAR2(40);
	WS_NM_PONTO		    VARCHAR2(80);
	WS_DS_PONTO		    VARCHAR2(2000);
	WS_TP_RENOVACAO		VARCHAR2(1);
	WS_CD_MICRO_VISAO	VARCHAR2(40);
	WS_PARAMETROS		VARCHAR2(30000);
	WS_VL_SALVO		    LONG;
	WS_CS_PARAMETROS	VARCHAR2(32000);
	WS_CS_COLUNA		VARCHAR2(2000);
	WS_CS_AGRUPADOR		VARCHAR2(2000);
	WS_CS_RP		    VARCHAR2(2000);
	WS_CS_COLUP		    VARCHAR2(2000);
  
	WS_CD_OBJETO		VARCHAR2(40);
	WS_NM_OBJETO		VARCHAR2(80);
	WS_TP_OBJETO		VARCHAR2(40);
	WS_CD_USUARIO		VARCHAR2(40);
	WS_ATRIBUTOS		VARCHAR2(4000);
	WS_DS_OBJETO		VARCHAR2(2000);

	WS_OBJ			VARCHAR2(60);
	WS_TIP			VARCHAR2(60);
	WS_REFERENCIA	VARCHAR2(60);
	WS_POSICAO		VARCHAR2(2000)	:=' ';
	WS_TAMANHO		VARCHAR2(2000)  :=' ';
	WS_GOUT			VARCHAR2(2000);

	WS_GVALORES		VARCHAR2(2000)  := ' ';
	WS_GROTULO		VARCHAR2(2000)  := ' ';
	WS_GDESCRICAO	VARCHAR2(2000)  := ' ';
	WS_SUBTITULO    VARCHAR2(2000)  := ' ';
	WS_VMAX			VARCHAR2(2000);
	WS_VMIN			VARCHAR2(2000);

	WS_POSX			VARCHAR2(20);
	WS_POSY			VARCHAR2(20);
	WS_ZINDEX		VARCHAR2(20);
	WS_COUNT		NUMBER;
	WS_SITUACAO     NUMBER;
	WS_RCOUNT       NUMBER;
	WS_PARAMETROSR  CLOB;
	WS_PARAMETRO    CLOB := '';
	WS_CLASS        VARCHAR2(60);
	WS_TALK         VARCHAR2(5) := 'talk';
	WS_STYLE        VARCHAR2(200);
	WS_FILTRO       VARCHAR2(2000);
	WS_TIPO         VARCHAR2(80);
	WS_GRADIENTE    VARCHAR2(2000);
	WS_PROPAGATION  VARCHAR2(400);
	WS_ORDER        VARCHAR2(50);
	WS_FORMULA      VARCHAR2(3000);
	WS_GRADIENTE_TIPO VARCHAR2(40);
	WS_DATA_COLUNA  VARCHAR2(500);
	WS_BORDA        VARCHAR2(60)   := '';
	WS_COMPLEMENTO  VARCHAR2(1400) := '';
	WS_COLUNA       VARCHAR2(400)  := '';
    WS_AGRUPADOR    VARCHAR2(400)  := '';
	WS_COLUP        VARCHAR2(400)  := '';
	WS_OBJID        VARCHAR2(400);
	WS_TEMPO        DATE;
	WS_SEC          VARCHAR2(400)  := '';
	
	WS_CURSOR	    INTEGER;
	WS_SQL		    VARCHAR2(2000);
	WS_VALOR        VARCHAR2(400);
	WS_VALORES      CLOB;
	WS_LINHAS       INTEGER;
	WS_ALINHAMENTO_TIT VARCHAR2(80);
	WS_LIGACAO      VARCHAR2(80);
	WS_VALOR_PONTO  VARCHAR2(200);
	WS_VALOR_META   VARCHAR2(200);
	WS_VALOR_UM     VARCHAR2(40);
	WS_USUARIO      VARCHAR2(80);
	WS_ADMIN        VARCHAR2(80);
	WS_PADRAO       VARCHAR2(80) := 'PORTUGUESE';

	WS_NOUSER       EXCEPTION;

BEGIN

	WS_USUARIO := PRM_USUARIO;
	WS_ADMIN   := PRM_ADMIN;

    IF NVL(WS_USUARIO, 'N/A') = 'N/A' THEN
		WS_USUARIO := GBL.GETUSUARIO;
	END IF;
	
	IF NVL(WS_ADMIN, 'N/A') = 'N/A' THEN
		WS_ADMIN   := NVL(GBL.GETNIVEL, 'N');
	END IF;

	IF NVL(WS_USUARIO, 'NOUSER') = 'NOUSER' THEN
		RAISE WS_NOUSER;
	END IF;

	SELECT SYSDATE INTO WS_TEMPO FROM DUAL;


    IF PRM_DASHBOARD <> 'false' THEN
	    WS_PROPAGATION := 'movingArticle(event);';
	ELSE
	    WS_PROPAGATION := '';
	END IF;

	IF PRM_DRILL = 'O' THEN
		HTP.P('<script>setTimeout(function(){ ajustar('''||PRM_OBJETO||''');}, 500);</script>');
	END IF;

	IF FUN.GETPROP(PRM_OBJETO, 'FILTRO') = 'PASSIVO' OR PRM_DRILL = 'C' THEN
		WS_PARAMETRO := REPLACE(PRM_PARAMETROS, '##', '|');
	END IF;

	IF FUN.GETPROP(PRM_OBJETO, 'FILTRO') = 'COM CORTE' THEN
		WS_PARAMETRO := SUBSTR(PRM_PARAMETROS, INSTR(PRM_PARAMETROS, '##')+2, 999);
	END IF;

	IF INSTR(PRM_OBJETO,'SECTION') = 0 THEN
		IF FUN.CHECK_PERMISSAO(PRM_OBJETO) = 'S' OR PRM_DRILL = 'C' THEN
			
			IF PRM_DRILL = 'C' THEN
                WS_CD_OBJETO := FUN.OBJCODE('COBJ_');
				WS_NM_OBJETO := 'CUSTOM';
				WS_TP_OBJETO := 'CONSULTA';
				WS_CD_USUARIO := WS_USUARIO;
				
				WS_OBJ := TRIM(WS_CD_OBJETO);
			    WS_TIP := TRIM(WS_TP_OBJETO);

                IF PRM_DRILL = 'C' THEN
					HTP.P('<script>setTimeout(function(){ topDistance('''||WS_OBJ||'''); }, 5000);</script>');
				END IF;

		    ELSE
				SELECT CD_OBJETO, 	NM_OBJETO,    TP_OBJETO,    CD_USUARIO,    ATRIBUTOS,    DS_OBJETO    INTO
					WS_CD_OBJETO, WS_NM_OBJETO, WS_TP_OBJETO, WS_CD_USUARIO, WS_ATRIBUTOS, WS_DS_OBJETO
				FROM   OBJETOS
				WHERE  CD_OBJETO=PRM_OBJETO;

				WS_OBJ := TRIM(PRM_OBJETO);
			    WS_TIP := TRIM(WS_TP_OBJETO);
			END IF;

			WS_POSX   := PRM_POSX;
			WS_POSY   := PRM_POSY;
			WS_ZINDEX := PRM_ZINDEX;
			IF  LENGTH(TRIM(WS_ZINDEX)) = 0 THEN
				WS_ZINDEX := '2';
			END IF;

			IF NVL(PRM_POSX,'NOLOC') = 'NOLOC' THEN
				IF PRM_DRILL = 'O' THEN
					WS_POSX := '0';
				ELSE
					WS_POSX := '200px';
				END IF;
			END IF;

			BEGIN
				IF PRM_DASHBOARD <> 'false' THEN
					WS_ORDER := 'order: '||WS_POSX||';';
				ELSE
					WS_ORDER := 'left: '||(TO_NUMBER(REPLACE(LOWER(WS_POSX), 'px', ''))+28)||'px';
				END IF;
			EXCEPTION WHEN OTHERS THEN
				WS_ORDER := '';
			END;

			IF WS_TP_OBJETO = 'TEXTO' AND WS_ADMIN <> 'A' THEN
				WS_POSY := (TO_NUMBER(REPLACE(LOWER(WS_POSY), 'px', ''))+28)||'px';
			END IF;

			IF NVL(PRM_POSY,'NOLOC') = 'NOLOC' THEN
				IF PRM_DRILL = 'O' THEN
					WS_POSY := '0';
				ELSE
					WS_POSY := '200px';
				END IF;
			END IF;

			IF PRM_DRILL = 'C' THEN
			    WS_GDESCRICAO := WS_NM_OBJETO;
			ELSE
			    SELECT NM_OBJETO, SUBTITULO INTO WS_GDESCRICAO, WS_SUBTITULO
				FROM   OBJETOS
				WHERE  CD_OBJETO=WS_OBJ;
			END IF;

			IF PRM_DRILL = 'Y' THEN
			    WS_CLASS := ' drill';
			END IF;
			
			IF WS_TP_OBJETO = 'MAPA' THEN
			    WS_CLASS := ' mapa';
			END IF;

			IF PRM_TRACK = 'INSIDE' THEN

				SELECT CD_PONTO, NM_PONTO, DS_PONTO, TP_RENOVACAO, CD_MICRO_VISAO, PARAMETROS, VL_SALVO, CS_PARAMETROS, CS_COLUNA, CS_AGRUPADOR, CS_RP, CS_COLUP INTO
					WS_CD_PONTO, WS_NM_PONTO, WS_DS_PONTO, WS_TP_RENOVACAO, WS_CD_MICRO_VISAO, WS_PARAMETROS, WS_VL_SALVO, WS_CS_PARAMETROS, WS_CS_COLUNA, WS_CS_AGRUPADOR, WS_CS_RP, WS_CS_COLUP
				FROM   PONTO_AVALIACAO
				WHERE  CD_PONTO = PRM_OBJETO;

				SELECT COUNT(*) INTO WS_COUNT FROM TABLE((FUN.VPIPE(WS_CS_COLUNA)));

				IF WS_COUNT > 1 THEN
					WS_COUNT := 0;
					FOR I IN (SELECT COLUMN_VALUE INTO WS_COUNT FROM TABLE((FUN.VPIPE(WS_CS_COLUNA)))) LOOP
						IF WS_COUNT = 0 THEN
							WS_CS_COLUNA := PRM_DRILL||'|';
						ELSE
							WS_CS_COLUNA := WS_CS_COLUNA||I.COLUMN_VALUE||'|';
						END IF;
						WS_COUNT := WS_COUNT+1;
					END LOOP;
				ELSE
					WS_CS_COLUNA := PRM_DRILL;
				END IF;

				WS_PARAMETROSR := WS_PARAMETRO;

				IF FUN.SETEM(WS_CS_PARAMETROS,'|') AND NVL(TRIM(WS_PARAMETROSR),'%$%')<>'%$%' THEN
					WS_CS_PARAMETROS := WS_CS_PARAMETROS||WS_PARAMETROSR;
				ELSE
					WS_CS_PARAMETROS := WS_PARAMETROSR;
				END IF;

				UPQUERY.SUBQUERY (PRM_OBJETO, WS_CS_PARAMETROS, RTRIM(WS_CD_MICRO_VISAO), WS_CS_COLUNA, WS_CS_AGRUPADOR, WS_CS_RP, WS_CS_COLUP, PRM_SCREEN, '', '', PRM_OBJETON, PRM_SELF);

			ELSE

			WS_POSICAO := ' position: absolute; top:'||WS_POSY||'; '||WS_ORDER||'';

			IF NVL(FUN.GETPROP(WS_OBJ,'DEGRADE_TIPO'), '%??%') = '%??%' THEN
			    WS_GRADIENTE_TIPO := 'linear';
			ELSE
			    WS_GRADIENTE_TIPO := FUN.GETPROP(WS_OBJ,'DEGRADE_TIPO');
			END IF;
 
			IF PRM_DASHBOARD <> 'false' THEN
	            WS_POSICAO := WS_POSICAO||' margin-top: '||FUN.GETPROP(PRM_OBJETO,'DASH_MARGIN_TOP',   PRM_SCREEN)||';'; 
				WS_POSICAO := WS_POSICAO||' margin-right: '||FUN.GETPROP(PRM_OBJETO,'DASH_MARGIN_RIGHT', PRM_SCREEN)||';';
				WS_POSICAO := WS_POSICAO||' margin-bottom: '||FUN.GETPROP(PRM_OBJETO,'DASH_MARGIN_BOT',   PRM_SCREEN)||';';
				WS_POSICAO := WS_POSICAO||' margin-left: '||FUN.GETPROP(PRM_OBJETO,'DASH_MARGIN_LEFT',  PRM_SCREEN)||';';
				WS_POSICAO := WS_POSICAO||' max-width: calc(100% - '||FUN.GETPROP(PRM_OBJETO,'DASH_MARGIN_LEFT', PRM_SCREEN)||' - '||FUN.GETPROP(PRM_OBJETO,'DASH_MARGIN_RIGHT', PRM_SCREEN)||');';
			END IF;

            
			BEGIN
				IF WS_TP_OBJETO NOT IN ('IMAGE', 'ICONE', 'TEXTO', 'CALL_LIST', 'FLOAT_FILTER', 'FLOAT_PAR', 'GEOMAPA', 'FILE', 'BROWSER', 'SPV', 'MARQUEE', 'SCRIPT', 'OBJETO', 'RELATORIO') THEN

					IF PRM_DRILL = 'C' THEN
					    
						WS_SITUACAO := 3;

						FOR I IN (SELECT COLUMN_VALUE VALOR, ROWNUM AS LINHA  FROM TABLE(FUN.VPIPE(WS_PARAMETRO, '||'))) LOOP
                            CASE I.LINHA
								WHEN '1' THEN
									WS_CS_COLUNA     := I.VALOR;
								WHEN '2' THEN
									WS_CS_AGRUPADOR  := I.VALOR;
								WHEN '3' THEN 
									WS_CS_COLUP      := I.VALOR;
								WHEN '4' THEN
									WS_CS_RP         := I.VALOR;
								WHEN '5' THEN
									WS_CS_PARAMETROS := I.VALOR;
								
							END CASE;
						END LOOP;

						WS_CD_MICRO_VISAO := PRM_OBJETO;

						IF LENGTH(WS_CS_PARAMETROS) > 0 THEN
						    WS_COMPLEMENTO := 'N/A';
							HTP.P('<ul id="custom-filtro" title="FILTROS APLICADOS">');
								FOR I IN(SELECT CD_COLUNA, CD_CONTEUDO, CD_CONDICAO, CD_COLUNA||'|$['||CD_CONDICAO||']'||CD_CONTEUDO AS LINHA, DECODE(TRIM(CD_CONDICAO), 'MAIOR','> ','MENOR','< ','') AS SINAL 
									FROM TABLE(FUN.VPIPE_PAR((WS_CS_PARAMETROS))) ORDER BY CD_COLUNA
									) LOOP
									IF I.CD_COLUNA <> WS_COMPLEMENTO THEN
									    SELECT CD_LIGACAO INTO WS_LIGACAO FROM MICRO_COLUNA WHERE CD_MICRO_VISAO = WS_CD_MICRO_VISAO AND CD_COLUNA = I.CD_COLUNA;

										HTP.P('</li>');
										HTP.P('<li title="'||FUN.CHECK_ROTULOC(I.CD_COLUNA, WS_CD_MICRO_VISAO)||'">');

										WS_COMPLEMENTO := I.CD_COLUNA;

									END IF;

                                    HTP.P('<span title="'||I.LINHA||'" class="'||I.CD_CONDICAO||'" onclick="removeCustomFiltro(this);">'||I.SINAL||' '||FUN.CDESC(I.CD_CONTEUDO, WS_LIGACAO)||'</span>');

								END LOOP;
							HTP.P('</ul>');
						END IF;

					ELSE
					
							SELECT COUNT(*) INTO WS_SITUACAO FROM PONTO_AVALIACAO WHERE CD_PONTO = PRM_OBJETO;
							SELECT CD_PONTO, NM_PONTO, DS_PONTO, TP_RENOVACAO, CD_MICRO_VISAO, PARAMETROS, VL_SALVO, CS_PARAMETROS, CS_COLUNA, CS_AGRUPADOR, CS_RP, CS_COLUP INTO
							WS_CD_PONTO, WS_NM_PONTO, WS_DS_PONTO, WS_TP_RENOVACAO, WS_CD_MICRO_VISAO, WS_PARAMETROS, WS_VL_SALVO, WS_CS_PARAMETROS, WS_CS_COLUNA, WS_CS_AGRUPADOR, WS_CS_RP, WS_CS_COLUP
							FROM   PONTO_AVALIACAO
							WHERE  CD_PONTO = PRM_OBJETO;
							
							IF NVL(TRIM(WS_CS_COLUNA), 'N/A') = 'N/A' THEN
								WS_SITUACAO := 2;
							END IF;
							IF NVL(TRIM(WS_CD_MICRO_VISAO), 'N/A') = 'N/A' THEN
								WS_SITUACAO := 2;
							END IF;
							IF NVL(TRIM(WS_CS_AGRUPADOR), 'N/A') = 'N/A' THEN
								WS_SITUACAO := 2;
							END IF;

							WS_PARAMETROS := WS_PARAMETRO||WS_PARAMETROS;

					END IF;
				ELSE
					IF WS_TP_OBJETO = 'OBJETO' THEN
						WS_SITUACAO := 2;
					ELSE
						WS_SITUACAO := 1;
					END IF;
				END IF;
	
			EXCEPTION WHEN OTHERS THEN
			    IF WS_TP_OBJETO = 'OBJETO' THEN
			        WS_SITUACAO := 2;
			    ELSE
				    IF PRM_DRILL = 'C' THEN
					    WS_SITUACAO := 3;
					ELSE
			            WS_SITUACAO := 2;
					END IF;
			    END IF;
			END;
			
			IF WS_SITUACAO = 0 THEN
				
				IF WS_ADMIN = 'A' THEN
					HTP.P('<div title="'||FUN.LANG('clique para remover')||'" style="cursor: pointer; position: absolute; background: #CC0000; color: #FFF; font-weight: bold; text-align: center; padding: 5px; border-radius: 5px; border: 1px solid #000;" onclick="if(document.getElementById('''||PRM_OBJETO||''')){ document.getElementById('''||PRM_OBJETO||''').style.display=''none''; } else { this.style.display = ''none''; } ajax(''fly'', ''remove_location'', ''prm_obj='||PRM_OBJETO||'&prm_screen=''+document.getElementById(''current_screen'').value, false); noerror('''', '''||FUN.LANG('Objeto removido com sucesso!')||''', ''feed-fixo'');">'||FUN.LANG('Erro ao carregar o PA do objeto')||' '||PRM_OBJETO||'</div>');
				ELSE
					HTP.P('<div title="'||FUN.LANG('clique para remover')||'" style="cursor: pointer; position: absolute; background: #CC0000; color: #FFF; font-weight: bold; text-align: center; padding: 5px; border-radius: 5px; border: 1px solid #000;">'||FUN.LANG('Erro ao carregar o PA do objeto')||' '||PRM_OBJETO||'</div>');
				END IF;
			ELSE
				CASE
				    WHEN WS_TP_OBJETO = 'CONSULTA' AND WS_SITUACAO <> 2 AND NVL(WS_NM_OBJETO, 'N/A') <> 'N/A' THEN
						
						IF PRM_DRILL <> 'C' THEN
							WS_PARAMETROSR := WS_PARAMETRO;

							IF FUN.SETEM(WS_CS_PARAMETROS,'|') AND NVL(TRIM(WS_PARAMETROSR),'%$%')<>'%$%' THEN
								WS_CS_PARAMETROS := WS_CS_PARAMETROS||WS_PARAMETROSR;
							ELSE
								WS_CS_PARAMETROS := WS_PARAMETROSR;
							END IF;

							IF PRM_ALT_MED <> 'no_change' THEN
								WS_CS_AGRUPADOR := PRM_ALT_MED;
							END IF;

						END IF;

						SELECT COUNT(*) INTO WS_COUNT FROM TABLE(FUN.VPIPE_PAR(WS_CS_COLUNA));

						IF FUN.PUT_PAR(PRM_OBJETO, 'CROSS', 'CONSULTA') = 'S' AND WS_COUNT = 0 AND NVL(TRIM(WS_CS_COLUP), 'null') = 'null' THEN
							IF PRM_CROSS = 'N' THEN
							   OBJ.CONSULTA(WS_CS_PARAMETROS, TRIM(WS_CD_MICRO_VISAO), WS_CS_COLUNA, WS_CS_AGRUPADOR, WS_CS_RP, WS_CS_COLUP, '', '', RTRIM(WS_CD_OBJETO), PRM_SCREEN => PRM_SCREEN, PRM_POSX => PRM_POSX, PRM_POSY => PRM_POSY, PRM_DRILL=> PRM_DRILL, PRM_ZINDEX => PRM_ZINDEX, PRM_TRACK => PRM_TRACK, PRM_OBJETON => PRM_OBJETON, PRM_SELF => PRM_SELF, PRM_DASHBOARD => PRM_DASHBOARD, PRM_PROPAGATION => WS_PROPAGATION);
							ELSE
							   UPQUERY.TAB_CROSS(WS_CS_PARAMETROS, TRIM(WS_CD_MICRO_VISAO), WS_CS_COLUNA, WS_CS_AGRUPADOR, WS_CS_RP, WS_CS_COLUP, '', '', RTRIM(WS_CD_OBJETO), PRM_SCREEN => PRM_SCREEN, PRM_POSX => PRM_POSX, PRM_POSY => PRM_POSY, PRM_DRILL=> PRM_DRILL, PRM_ZINDEX => PRM_ZINDEX, PRM_TRACK => PRM_TRACK, PRM_OBJETON => PRM_OBJETON, PRM_DASHBOARD => PRM_DASHBOARD );
							END IF;
						ELSE
							IF PRM_CROSS = 'S' THEN
								UPQUERY.TAB_CROSS(WS_CS_PARAMETROS, TRIM(WS_CD_MICRO_VISAO), WS_CS_COLUNA, WS_CS_AGRUPADOR, WS_CS_RP, WS_CS_COLUP, '', '', RTRIM(WS_CD_OBJETO), PRM_SCREEN => PRM_SCREEN, PRM_POSX => PRM_POSX, PRM_POSY => PRM_POSY, PRM_DRILL=> PRM_DRILL, PRM_ZINDEX => PRM_ZINDEX, PRM_TRACK => PRM_TRACK, PRM_OBJETON => PRM_OBJETON, PRM_DASHBOARD => PRM_DASHBOARD );
							ELSE
							    IF PRM_DRILL = 'C' THEN
								    OBJ.CONSULTA(WS_CS_PARAMETROS, TRIM(WS_CD_MICRO_VISAO), WS_CS_COLUNA, WS_CS_AGRUPADOR, NVL(WS_CS_RP, 'ROLL'), WS_CS_COLUP, '', '', RTRIM(WS_CD_OBJETO), PRM_SCREEN => PRM_SCREEN, PRM_POSX => PRM_POSX, PRM_POSY => PRM_POSY, PRM_DRILL=> PRM_DRILL, PRM_ZINDEX => PRM_ZINDEX, PRM_TRACK => PRM_TRACK, PRM_OBJETON => PRM_OBJETON, PRM_SELF => PRM_SELF, PRM_DASHBOARD => PRM_DASHBOARD, PRM_PROPAGATION => WS_PROPAGATION);
								ELSE
								    OBJ.CONSULTA(WS_CS_PARAMETROS, TRIM(WS_CD_MICRO_VISAO), WS_CS_COLUNA, WS_CS_AGRUPADOR, WS_CS_RP, WS_CS_COLUP, '', '', RTRIM(WS_CD_OBJETO), PRM_SCREEN => PRM_SCREEN, PRM_POSX => PRM_POSX, PRM_POSY => PRM_POSY, PRM_DRILL=> PRM_DRILL, PRM_ZINDEX => PRM_ZINDEX, PRM_TRACK => PRM_TRACK, PRM_OBJETON => PRM_OBJETON, PRM_SELF => PRM_SELF, PRM_DASHBOARD => PRM_DASHBOARD, PRM_PROPAGATION => WS_PROPAGATION);
							    END IF;
							END IF;
						END IF;

				    WHEN WS_TP_OBJETO = 'CALL_LIST' THEN
				        
						OBJ.MENU(WS_OBJ, PRM_SCREEN, WS_POSICAO, WS_POSY, WS_POSX);

				    WHEN WS_TP_OBJETO = 'FLOAT_PAR' THEN
					    
				        OBJ.FLOAT_PAR(WS_OBJ);

				    WHEN WS_TP_OBJETO = 'FLOAT_FILTER' THEN
					    
						OBJ.FLOAT_FILTER(WS_OBJ);

				    WHEN WS_TP_OBJETO = 'VALOR' THEN

						OBJ.VALOR(WS_OBJ, PRM_DRILL, WS_GDESCRICAO, WS_CD_MICRO_VISAO, WS_PARAMETROS, WS_PROPAGATION, PRM_SCREEN, WS_POSX, WS_POSY, WS_POSICAO, WS_USUARIO);
									
						IF FUN.GETPROP(PRM_OBJETO, 'QUERY_STAT') = 'S' OR (SYSDATE > WS_TEMPO+(0.00023148148148148146)) THEN
							INSERT INTO QUERY_STAT VALUES(WS_USUARIO, SYSDATE, PRM_OBJETO, WS_CD_MICRO_VISAO, '', SUBSTR(WS_PARAMETROS, 1 ,INSTR(WS_PARAMETROS,'|')-1), '', '', '', '', ((SYSDATE-WS_TEMPO)*1440)*60*1000);
						END IF;

					WHEN WS_TP_OBJETO = 'PONTEIRO' THEN

					    BEGIN
							OBJ.PONTEIRO(PRM_OBJETO, PRM_DRILL, WS_GDESCRICAO, WS_CD_MICRO_VISAO, NVL(WS_PARAMETROS, WS_CS_AGRUPADOR||'|'), WS_PROPAGATION, PRM_SCREEN, WS_POSX, WS_POSY, WS_POSICAO);
						END;

						IF FUN.GETPROP(PRM_OBJETO, 'QUERY_STAT') = 'S' OR (SYSDATE > WS_TEMPO+(0.00023148148148148146)) THEN
							INSERT INTO QUERY_STAT VALUES(WS_USUARIO, SYSDATE, PRM_OBJETO, WS_CD_MICRO_VISAO, '', SUBSTR(WS_PARAMETROS, 1 ,INSTR(WS_PARAMETROS,'|')-1), '', '', '', '', ((SYSDATE-WS_TEMPO)*1440)*60*1000);
						END IF;

				    WHEN WS_TP_OBJETO IN ('LINHAS','BARRAS', 'COLUNAS', 'PIZZA', 'ROSCA', 'MAPA') AND WS_SITUACAO <> 2 AND NVL(WS_NM_OBJETO, 'N/A') <> 'N/A' THEN
						
						OBJ.GRAFICO(PRM_OBJETO, PRM_DRILL, WS_GDESCRICAO, WS_CD_MICRO_VISAO, WS_PARAMETROS, WS_PROPAGATION, PRM_SCREEN, WS_POSX, WS_POSY, WS_POSICAO, PRM_DASHBOARD);
						
						IF FUN.GETPROP(PRM_OBJETO, 'QUERY_STAT') = 'S' OR (SYSDATE > WS_TEMPO+(0.00023148148148148146)) THEN
							INSERT INTO QUERY_STAT VALUES(WS_USUARIO, SYSDATE, PRM_OBJETO, WS_CD_MICRO_VISAO, '', SUBSTR(WS_PARAMETROS, 1 ,INSTR(WS_PARAMETROS,'|')-1), '', '', '', '', ((SYSDATE-WS_TEMPO)*1440)*60*1000);
						END IF;

				    WHEN WS_TP_OBJETO = 'OBJETO' OR WS_SITUACAO = 2 OR NVL(WS_NM_OBJETO, 'N/A') = 'N/A' THEN
						IF WS_ADMIN = 'A' THEN
							SELECT DECODE(TP_OBJETO, 'OBJETO', 'BARRAS', TP_OBJETO) INTO WS_TIPO FROM OBJETOS WHERE CD_OBJETO = PRM_OBJETO;

							IF SUBSTR(TRIM(FUN.PUT_STYLE(WS_OBJ, 'DEGRADE', WS_TIP)), 5, 1) = 'S' THEN
								IF NVL(FUN.GETPROP(WS_OBJ,'DEGRADE_TIPO'), '%??%') = '%??%' THEN
									WS_GRADIENTE_TIPO := 'linear';
								ELSE
									WS_GRADIENTE_TIPO := FUN.GETPROP(WS_OBJ,'DEGRADE_TIPO');
								END IF;
								WS_GRADIENTE := 'background: '||WS_GRADIENTE_TIPO||'-gradient('||SUBSTR(FUN.PUT_STYLE(WS_OBJ, 'TIT_BGCOLOR', WS_TIP), 18, 7)||', '||SUBSTR(FUN.PUT_STYLE(WS_OBJ, 'BGCOLOR', WS_TIP), 18, 7)||');';
							ELSE
								WS_GRADIENTE := FUN.PUT_STYLE(WS_OBJ, 'BGCOLOR', WS_TIP);
							END IF;

							WS_OBJID := PRM_OBJETO;

							SELECT COUNT(*) INTO WS_COUNT FROM GOTO_OBJETO WHERE CD_OBJETO = PRM_OBJETO;

							WS_GOTO := '';

							HTP.P('<div class="dragme generico'||WS_CLASS||'" onclick="if(objatual != this.id){ objatual = this.id; }" id="'||WS_OBJID||'" onmousedown="'||WS_PROPAGATION||'" ontouchstart="swipeStart('''||WS_OBJ||''', event);" ontouchmove="swipe('''||WS_OBJ||''', event);" ontouchend="swipe('''||WS_OBJ||''', event);" style="'||WS_GRADIENTE||' border-color: 1px solid #999; '||WS_POSICAO||';">');

							IF FUN.GETPROP(PRM_OBJETO,'NO_RADIUS') <> 'N' THEN
								HTP.P('<style>div#'||PRM_OBJETO||', div#'||PRM_OBJETO||'_ds { border-radius: 0; } div#'||PRM_OBJETO||' span#'||PRM_OBJETO||'more { border-radius: 0 0 6px 0; } a#'||PRM_OBJETO||'fechar { border-radius: 0 0 0 6px; }</style>');
							END IF;

							OBJ.OPCOES(WS_OBJID, 'GENERICO', '', '', PRM_SCREEN, '', '', '', PRM_USUARIO => WS_USUARIO);
							
							WS_POSICAO := 'width: 400px;';
							
							HTP.P('<div data-tipoobj="'||WS_TP_OBJETO||'" id="dados_'||TRIM(WS_OBJID)||'" data-heatmap="'||FUN.GETPROP(PRM_OBJETO, 'HEATMAP')||'" data-funil-sort="'||FUN.GETPROP(PRM_OBJETO, 'FUNIL_SORT')||'" data-funil="'||FUN.GETPROP(PRM_OBJETO, 'FUNIL')||'"  data-ccoluna-hex="'||FUN.GETPROP(PRM_OBJETO, 'COR-COLUNA-HEX')||'" data-maximo="'||FUN.XFORMULA(FUN.GETPROP(PRM_OBJETO, 'MAXIMO'), PRM_SCREEN)||'" data-dashboard="'||PRM_DASHBOARD||'" data-filtro="'||WS_FILTRO||'" data-drill="'||WS_GOTO||'" data-sec="'||FUN.CHECK_ROTULOC(FUN.GETPROP(PRM_OBJETO, 'SEC'), WS_CD_MICRO_VISAO)||'" data-coluna="'||FUN.CHECK_ROTULOC(WS_COLUNA, WS_CD_MICRO_VISAO)||'" data-colunareal="'||WS_COLUNA||'" data-agrupadoresreal="'||WS_AGRUPADOR||'" data-agrupadores="'||FUN.CHECK_ROTULOC(WS_AGRUPADOR, WS_CD_MICRO_VISAO)||'"  data-refresh="8000" data-tipo="'||WS_TIPO||'" data-top="'||WS_POSY||'" data-left="'||WS_POSX||'" data-swipe="" style="display: none;"></div>');

							IF SUBSTR(TRIM(FUN.PUT_STYLE(WS_OBJ, 'DEGRADE', WS_TIPO)), 5, 1) = 'S' THEN
								WS_GRADIENTE := '';
							ELSE
								WS_GRADIENTE := FUN.PUT_STYLE(WS_OBJ, 'TIT_BGCOLOR', WS_TIPO);
							END IF;

							WS_ALINHAMENTO_TIT := FUN.GETPROP(PRM_OBJETO,'ALIGN_TIT');
							IF WS_ALINHAMENTO_TIT = 'left' THEN
								WS_ALINHAMENTO_TIT := WS_ALINHAMENTO_TIT||'; text-indent: 14px';
							END IF;
							
							BEGIN
								SELECT CONTEUDO INTO WS_PADRAO
								FROM   PARAMETRO_USUARIO
								WHERE  CD_USUARIO = WS_USUARIO AND
									CD_PADRAO='CD_LINGUAGEM';
							EXCEPTION
								WHEN OTHERS THEN
									WS_PADRAO := 'PORTUGUESE';
							END;
							
							IF WS_ADMIN = 'A' THEN
								HTP.P('<div data-touch="0" class="wd_move" title="'||FUN.LANG('Clique e arraste para mover, duplo clique para ampliar')||'" style="text-align: '||WS_ALINHAMENTO_TIT||'; '||FUN.PUT_STYLE(WS_OBJ, 'TIT_COLOR', WS_TIPO)||WS_GRADIENTE||FUN.PUT_STYLE(WS_OBJ, 'TIT_IT', WS_TIPO)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BOLD', WS_TIPO)||FUN.PUT_STYLE(WS_OBJ, 'TIT_FONT', WS_TIPO)||FUN.PUT_STYLE(WS_OBJ, 'TIT_SIZE', WS_TIPO)||'" id="'||PRM_OBJETO||'_ds">'||NVL(FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', PRM_OBJETO, WS_GDESCRICAO, WS_PADRAO), PRM_SCREEN), 'OBJETO')||'</div>');
							ELSE
								HTP.P('<div data-touch="0" style="padding: 5px; border-radius: 7px 7px 0 0; cursor: default; text-align: '||WS_ALINHAMENTO_TIT||'; '||FUN.PUT_STYLE(WS_OBJ, 'TIT_COLOR', WS_TIPO)||WS_GRADIENTE||FUN.PUT_STYLE(WS_OBJ, 'TIT_IT', WS_TIPO)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BOLD', WS_TIPO)||FUN.PUT_STYLE(WS_OBJ, 'TIT_FONT', WS_TIPO)||FUN.PUT_STYLE(WS_OBJ, 'TIT_SIZE', WS_TIPO)||'" id="'||PRM_OBJETO||'_ds">'||NVL(FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', PRM_OBJETO, WS_GDESCRICAO, WS_PADRAO), PRM_SCREEN), 'OBJETO')||'</div>');
							END IF;

							HTP.P('<div class="sub" id="'||PRM_OBJETO||'_sub" style="text-align: '||WS_ALINHAMENTO_TIT||'; '||FUN.PUT_STYLE(WS_OBJ, 'TIT_COLOR', WS_TIPO)||';">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', WS_OBJ, WS_SUBTITULO, WS_PADRAO), PRM_SCREEN)||'</div>');

							IF WS_TP_OBJETO = 'OBJETO' THEN
							
								HTP.P('<ul class="queryadd" title="'||WS_TP_OBJETO||'">');   
									HTP.P('<li title="GR&Aacute;FICO" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||PRM_OBJETO||'&prm_tipo=grafico''); this.classList.add(''single''); this.nextElementSibling.classList.add(''removed'');">');
										HTP.P('<svg style="" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 480 480" style="enable-background:new 0 0 480 480;" xml:space="preserve"> <g> <g> <path d="M316.211,123.858l-69.281-120c-2.544-3.827-7.708-4.868-11.536-2.324c-0.921,0.612-1.711,1.402-2.324,2.324l-69.281,120 c-2.209,3.826-0.898,8.719,2.928,10.928c1.217,0.702,2.597,1.072,4.001,1.072h138.563c4.418,0.001,8.001-3.58,8.001-7.999 C317.283,126.455,316.913,125.074,316.211,123.858z M184.574,119.858l55.426-96l55.426,96H184.574z"/> </g> </g> <g> <g> <path d="M472.004,335.858c-0.001,0-0.003,0-0.004,0H344c-4.417-0.001-7.999,3.579-8,7.996c0,0.001,0,0.003,0,0.004v128 c-0.001,4.417,3.579,7.999,7.996,8c0.001,0,0.003,0,0.004,0h128c4.417,0.001,7.999-3.579,8-7.996c0-0.001,0-0.003,0-0.004v-128 C480.001,339.441,476.421,335.859,472.004,335.858z M464,463.858H352v-112h112V463.858z"/> </g> </g> <g> <g> <path d="M72,335.858c-39.765,0-72,32.235-72,72c0,39.764,32.235,72,72,72s72-32.236,72-72 C143.955,368.112,111.746,335.903,72,335.858z M72,463.858c-30.928,0-56-25.072-56-56c0-30.928,25.072-56,56-56 c30.928,0,56,25.072,56,56C127.964,438.771,102.913,463.822,72,463.858z"/> </g> </g> <g> <g> <path d="M163.336,88.538l-6.672-14.547C62.627,117.189,16.991,224.92,51.383,322.522l15.086-5.328 C34.834,227.396,76.822,128.284,163.336,88.538z"/> </g> </g> <g> <g> <path d="M309,426.491c-21.921,8.869-45.353,13.409-69,13.367c-25.347,0.054-50.427-5.166-73.648-15.328l-6.406,14.656 c49.31,21.464,105.173,22.233,155.055,2.133L309,426.491z"/> </g> </g> <g> <g> <path d="M336.908,80.869l0.002-0.003c-1.734-0.961-3.488-1.906-5.254-2.813l-7.312,14.234c1.609,0.828,3.204,1.682,4.785,2.562 l3.891-6.992l-3.883,6.992c58.511,32.463,94.824,94.095,94.863,161.008c0.015,18.185-2.664,36.272-7.949,53.672l15.305,4.656 C458.787,223.874,419.438,126.668,336.908,80.869z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
										
										HTP.P('<span>'||FUN.LANG('GR&Aacute;FICO')||'</span>');
									HTP.P('</li>');
									HTP.P('<li title="CONSULTA" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||PRM_OBJETO||'&prm_tipo=consulta''); this.classList.add(''single''); this.previousElementSibling.classList.add(''removed'');">');
										HTP.P('<svg style="margin-top: 8px;" version="1.1"  xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 502 502" style="enable-background:new 0 0 502 502;" xml:space="preserve"> <g> <g> <g> <path d="M492,56.375H10c-5.522,0-10,4.477-10,10v369.25c0,5.523,4.478,10,10,10h482c5.522,0,10-4.477,10-10V66.375 C502,60.852,497.522,56.375,492,56.375z M120.5,425.625H20v-53.896h100.5V425.625z M120.5,351.728H20v-53.896h100.5V351.728z M120.5,277.832H20v-53.896h100.5V277.832z M120.5,203.935H20v-53.664h100.5V203.935z M241,425.625H140.5v-53.896H241V425.625z M241,351.728H140.5v-53.896H241V351.728z M241,277.832H140.5v-53.896H241V277.832z M241,203.935H140.5v-53.664H241V203.935z M361.5,425.625H261v-53.896h100.5V425.625z M361.5,351.728H261v-53.896h100.5V351.728z M361.5,277.832H261v-53.896h100.5 V277.832z M361.5,203.935H261v-53.664h100.5V203.935z M482,425.625H381.5v-53.896H482V425.625z M482,351.728H381.5v-53.896H482 V351.728z M482,277.832H381.5v-53.896H482V277.832z M482,203.936H381.5v-53.664H482V203.936z M482,130.039H20V76.375h462V130.039 z"/> <path d="M209,107.625h192c5.522,0,10-4.477,10-10s-4.478-10-10-10H209c-5.522,0-10,4.477-10,10S203.478,107.625,209,107.625z"/> <path d="M436,107.625h22c5.522,0,10-4.477,10-10s-4.478-10-10-10h-22c-5.522,0-10,4.477-10,10S430.478,107.625,436,107.625z"/> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
										HTP.P('<span style="margin-top: -3px;">'||FUN.LANG('CONSULTA')||'</span>');
									HTP.P('</li>');
								HTP.P('</ul>');
							
							ELSIF WS_TP_OBJETO = 'CONSULTA' THEN
							
							    HTP.P('<ul class="queryadd" title="'||WS_TP_OBJETO||'">');   
									HTP.P('<li class="removed" title="GR&Aacute;FICO" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||PRM_OBJETO||'&prm_tipo=grafico''); this.classList.add(''single''); this.nextElementSibling.classList.add(''removed'');">');
										
										HTP.P('<svg viewBox="0 0 19 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M7.71183 11.8399V19.4743H0.0644531V11.8399H7.71183ZM8.66775 0.770142L13.8297 9.35879H3.3146L8.66775 0.770142ZM13.8297 11.2674C14.9768 11.2674 16.1239 11.6491 16.8887 12.6034C17.6534 13.5577 18.0358 14.512 18.0358 15.6571C18.0358 16.8023 17.6534 17.9474 16.8887 18.7109C16.1239 19.4743 14.9768 19.856 13.8297 19.856C12.6826 19.856 11.5355 19.4743 10.7708 18.7109C10.006 17.9474 9.62367 16.8023 9.62367 15.6571C9.62367 14.512 10.006 13.3668 10.7708 12.6034C11.5355 11.8399 12.6826 11.2674 13.8297 11.2674Z" fill="#191147"/></svg>');
										HTP.P('<span>'||FUN.LANG('GR&Aacute;FICO')||'</span>');
									HTP.P('</li>');
									HTP.P('<li class="single" title="CONSULTA" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||PRM_OBJETO||'&prm_tipo=consulta''); this.classList.add(''single''); this.previousElementSibling.classList.add(''removed'');">');
										HTP.P('<svg style="margin-top: 8px;" version="1.1"  xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 502 502" style="enable-background:new 0 0 502 502;" xml:space="preserve"> <g> <g> <g> <path d="M492,56.375H10c-5.522,0-10,4.477-10,10v369.25c0,5.523,4.478,10,10,10h482c5.522,0,10-4.477,10-10V66.375 C502,60.852,497.522,56.375,492,56.375z M120.5,425.625H20v-53.896h100.5V425.625z M120.5,351.728H20v-53.896h100.5V351.728z M120.5,277.832H20v-53.896h100.5V277.832z M120.5,203.935H20v-53.664h100.5V203.935z M241,425.625H140.5v-53.896H241V425.625z M241,351.728H140.5v-53.896H241V351.728z M241,277.832H140.5v-53.896H241V277.832z M241,203.935H140.5v-53.664H241V203.935z M361.5,425.625H261v-53.896h100.5V425.625z M361.5,351.728H261v-53.896h100.5V351.728z M361.5,277.832H261v-53.896h100.5 V277.832z M361.5,203.935H261v-53.664h100.5V203.935z M482,425.625H381.5v-53.896H482V425.625z M482,351.728H381.5v-53.896H482 V351.728z M482,277.832H381.5v-53.896H482V277.832z M482,203.936H381.5v-53.664H482V203.936z M482,130.039H20V76.375h462V130.039 z"/> <path d="M209,107.625h192c5.522,0,10-4.477,10-10s-4.478-10-10-10H209c-5.522,0-10,4.477-10,10S203.478,107.625,209,107.625z"/> <path d="M436,107.625h22c5.522,0,10-4.477,10-10s-4.478-10-10-10h-22c-5.522,0-10,4.477-10,10S430.478,107.625,436,107.625z"/> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
										HTP.P('<span style="margin-top: -3px;">'||FUN.LANG('CONSULTA')||'</span>');
									HTP.P('</li>');
								HTP.P('</ul>');
							
							ELSE
							
							    HTP.P('<ul class="queryadd" title="'||WS_TP_OBJETO||'">');   
									HTP.P('<li class="single" title="GR&Aacute;FICO" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||PRM_OBJETO||'&prm_tipo=grafico''); this.classList.add(''single''); this.nextElementSibling.classList.add(''removed'');">');
										
										HTP.P('<svg style="" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 480 480" style="enable-background:new 0 0 480 480;" xml:space="preserve"> <g> <g> <path d="M316.211,123.858l-69.281-120c-2.544-3.827-7.708-4.868-11.536-2.324c-0.921,0.612-1.711,1.402-2.324,2.324l-69.281,120 c-2.209,3.826-0.898,8.719,2.928,10.928c1.217,0.702,2.597,1.072,4.001,1.072h138.563c4.418,0.001,8.001-3.58,8.001-7.999 C317.283,126.455,316.913,125.074,316.211,123.858z M184.574,119.858l55.426-96l55.426,96H184.574z"/> </g> </g> <g> <g> <path d="M472.004,335.858c-0.001,0-0.003,0-0.004,0H344c-4.417-0.001-7.999,3.579-8,7.996c0,0.001,0,0.003,0,0.004v128 c-0.001,4.417,3.579,7.999,7.996,8c0.001,0,0.003,0,0.004,0h128c4.417,0.001,7.999-3.579,8-7.996c0-0.001,0-0.003,0-0.004v-128 C480.001,339.441,476.421,335.859,472.004,335.858z M464,463.858H352v-112h112V463.858z"/> </g> </g> <g> <g> <path d="M72,335.858c-39.765,0-72,32.235-72,72c0,39.764,32.235,72,72,72s72-32.236,72-72 C143.955,368.112,111.746,335.903,72,335.858z M72,463.858c-30.928,0-56-25.072-56-56c0-30.928,25.072-56,56-56 c30.928,0,56,25.072,56,56C127.964,438.771,102.913,463.822,72,463.858z"/> </g> </g> <g> <g> <path d="M163.336,88.538l-6.672-14.547C62.627,117.189,16.991,224.92,51.383,322.522l15.086-5.328 C34.834,227.396,76.822,128.284,163.336,88.538z"/> </g> </g> <g> <g> <path d="M309,426.491c-21.921,8.869-45.353,13.409-69,13.367c-25.347,0.054-50.427-5.166-73.648-15.328l-6.406,14.656 c49.31,21.464,105.173,22.233,155.055,2.133L309,426.491z"/> </g> </g> <g> <g> <path d="M336.908,80.869l0.002-0.003c-1.734-0.961-3.488-1.906-5.254-2.813l-7.312,14.234c1.609,0.828,3.204,1.682,4.785,2.562 l3.891-6.992l-3.883,6.992c58.511,32.463,94.824,94.095,94.863,161.008c0.015,18.185-2.664,36.272-7.949,53.672l15.305,4.656 C458.787,223.874,419.438,126.668,336.908,80.869z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
										HTP.P('<span>'||FUN.LANG('GR&Aacute;FICO')||'</span>');
									HTP.P('</li>');
									HTP.P('<li class="removed" title="CONSULTA" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||PRM_OBJETO||'&prm_tipo=consulta''); this.classList.add(''single''); this.previousElementSibling.classList.add(''removed'');">');
										HTP.P('<svg style="margin-top: 8px;" version="1.1"  xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 502 502" style="enable-background:new 0 0 502 502;" xml:space="preserve"> <g> <g> <g> <path d="M492,56.375H10c-5.522,0-10,4.477-10,10v369.25c0,5.523,4.478,10,10,10h482c5.522,0,10-4.477,10-10V66.375 C502,60.852,497.522,56.375,492,56.375z M120.5,425.625H20v-53.896h100.5V425.625z M120.5,351.728H20v-53.896h100.5V351.728z M120.5,277.832H20v-53.896h100.5V277.832z M120.5,203.935H20v-53.664h100.5V203.935z M241,425.625H140.5v-53.896H241V425.625z M241,351.728H140.5v-53.896H241V351.728z M241,277.832H140.5v-53.896H241V277.832z M241,203.935H140.5v-53.664H241V203.935z M361.5,425.625H261v-53.896h100.5V425.625z M361.5,351.728H261v-53.896h100.5V351.728z M361.5,277.832H261v-53.896h100.5 V277.832z M361.5,203.935H261v-53.664h100.5V203.935z M482,425.625H381.5v-53.896H482V425.625z M482,351.728H381.5v-53.896H482 V351.728z M482,277.832H381.5v-53.896H482V277.832z M482,203.936H381.5v-53.664H482V203.936z M482,130.039H20V76.375h462V130.039 z"/> <path d="M209,107.625h192c5.522,0,10-4.477,10-10s-4.478-10-10-10H209c-5.522,0-10,4.477-10,10S203.478,107.625,209,107.625z"/> <path d="M436,107.625h22c5.522,0,10-4.477,10-10s-4.478-10-10-10h-22c-5.522,0-10,4.477-10,10S430.478,107.625,436,107.625z"/> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
										HTP.P('<span style="margin-top: -3px;">'||FUN.LANG('CONSULTA')||'</span>');
									HTP.P('</li>');
								HTP.P('</ul>');
							
							END IF;
								
							HTP.P('<div id="ctnr_'||WS_OBJID||'" class="block-fusion espaco" style="position: relative !important; min-width: inherit; max-width: inherit; '||WS_POSICAO||';"></div>');

							FCL.DATA_ATTRIB(WS_OBJID, WS_TIPO);

							HTP.P('</div>');
						END IF;

				    WHEN WS_TP_OBJETO= 'ICONE' THEN

						OBJ.ICONE(PRM_OBJETO, WS_PROPAGATION, PRM_SCREEN, PRM_DRILL, WS_NM_OBJETO, WS_POSICAO, WS_POSY, WS_POSX);

				    WHEN WS_TP_OBJETO = 'IMAGE' THEN

					    OBJ.IMAGE(PRM_OBJETO, WS_PROPAGATION, PRM_SCREEN, PRM_DRILL, WS_NM_OBJETO, WS_POSICAO, WS_POSY, WS_POSX);

				    WHEN WS_TP_OBJETO = 'FILE' THEN

                        OBJ.FILE(PRM_OBJETO, WS_PROPAGATION, PRM_SCREEN, PRM_DRILL, WS_NM_OBJETO, WS_POSICAO, WS_POSY, WS_POSX);

				    WHEN WS_TP_OBJETO IN ('UPGETPAR','CH_PASS') THEN
						HTP.P('<div src="DWU.fcl.ch_pwd"><script>alert(DWU.fcl.ch_pwd);</script></div>');
						IF  WS_TP_OBJETO = 'UPGETPAR' THEN
							HTP.P( '<iframe width="100%" height="100%" name="'||WS_OBJ||'_file"  src="DWU.fcl.get_par?ws_type=SUBMIT" style=" background:#CDCDC1; border:0px; padding:0px; '||FUN.PUT_STYLE(WS_OBJ, 'TIT_COLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BGCOLOR', WS_TIP)||'; "></iframe>');
						ELSE
							HTP.P( '<iframe width="100%" height="100%" name="'||WS_OBJ||'_file"  src="DWU.fcl.ch_pwd" style=" background:#CDCDC1; border:0px; padding:0px; '||FUN.PUT_STYLE(WS_OBJ, 'TIT_COLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BGCOLOR', WS_TIP)||'; "></iframe>');
						END IF;
						
				    WHEN WS_TP_OBJETO= 'RELATORIO' THEN

					    OBJ.RELATORIO(PRM_OBJETO, WS_PROPAGATION, PRM_SCREEN, PRM_DRILL, WS_NM_OBJETO, WS_POSICAO, WS_POSY, WS_POSX);
				    
				    WHEN WS_TP_OBJETO = 'GEOMAPA' THEN
						
						HTP.P('<div style="height: 100%; width: 100%; position: absolute; top: 0; left: 0;" id="'||PRM_OBJETO||'" class="dragme geomapa"></div>');
                    
				    WHEN WS_TP_OBJETO = 'TEXTO' THEN
                        
						BEGIN
							SELECT CONTEUDO INTO WS_PADRAO
							FROM   PARAMETRO_USUARIO
							WHERE  CD_USUARIO = WS_USUARIO AND
								CD_PADRAO='CD_LINGUAGEM';
						EXCEPTION
							WHEN OTHERS THEN
								WS_PADRAO := 'PORTUGUESE';
						END;
						
						IF FUN.GETPROP(PRM_OBJETO,'MARQUEE') = 'S' THEN
						    HTP.P('<div onmousedown="'||WS_PROPAGATION||'" class="dragme marquee" id="'||TRIM(PRM_OBJETO)||'" data-top="'||WS_POSY||'" data-left="'||WS_POSX||'" style="width: calc('||FUN.GETPROP(PRM_OBJETO,'LARGURA')||' - 2px); white-space: nowrap; '||WS_POSICAO||'; '||FUN.PUT_STYLE(WS_OBJ, 'COLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'BGCOLOR', WS_TIP)||'" ondbclick=" call_save(''enabled''); carrega(''av_prop?ws_par_sumary='||PRM_OBJETO||'&prm_screen='||PRM_SCREEN||'''); showedobj(''hide'');">');
						ELSE
                            HTP.P('<div onmousedown="'||WS_PROPAGATION||'" class="dragme texto" id="'||TRIM(PRM_OBJETO)||'" data-top="'||WS_POSY||'" data-left="'||WS_POSX||'" style="white-space: nowrap; '||WS_POSICAO||'; '||WS_BORDA||FUN.PUT_STYLE(WS_OBJ, 'COLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'BGCOLOR', WS_TIP)||'" ondbclick=" call_save(''enabled''); carrega(''av_prop?ws_par_sumary='||PRM_OBJETO||'&prm_screen='||PRM_SCREEN||'''); showedobj(''hide'');">');
                        END IF;

	                    OBJ.OPCOES(PRM_OBJETO, WS_TP_OBJETO, '', '', PRM_SCREEN, PRM_DRILL, PRM_USUARIO => WS_USUARIO);
							HTP.P('<span id="valor_'||PRM_OBJETO||'" class="texto" style="'||FUN.PUT_STYLE(WS_OBJ, 'IT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'BOLD', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'FONT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'SIZE', WS_TIP)||' text-align: center; display: block; min-width: 70px; white-space: pre;" ><p>'||FUN.SUBPAR(FUN.UTRANSLATE('ATRIBUTOS', WS_OBJ, FUN.SUBPAR(WS_ATRIBUTOS, PRM_SCREEN), WS_PADRAO), PRM_SCREEN)||'</p></span>');
					    HTP.P('</div>');

					WHEN WS_TP_OBJETO = 'MAPAFUSION' THEN
						
						BEGIN
							SELECT CONTEUDO INTO WS_PADRAO
							FROM   PARAMETRO_USUARIO
							WHERE  CD_USUARIO = WS_USUARIO AND
								CD_PADRAO='CD_LINGUAGEM';
						EXCEPTION
							WHEN OTHERS THEN
								WS_PADRAO := 'PORTUGUESE';
						END;
						
						IF SUBSTR(TRIM(FUN.PUT_STYLE(WS_OBJ, 'DEGRADE', WS_TIP)), 5, 1) = 'S' THEN
							WS_GRADIENTE := 'background: '||WS_GRADIENTE_TIPO||'-gradient('||SUBSTR(FUN.PUT_STYLE(WS_OBJ, 'TIT_BGCOLOR', WS_TIP), 18, 7)||', '||SUBSTR(FUN.PUT_STYLE(WS_OBJ, 'BGCOLOR', WS_TIP), 18, 7)||'); ';
						ELSE
							WS_GRADIENTE := FUN.PUT_STYLE(WS_OBJ, 'BGCOLOR', WS_TIP);
						END IF;

						IF FUN.GETPROP(PRM_OBJETO,'NO_RADIUS') <> 'N' THEN
							HTP.P('<style>div#'||PRM_OBJETO||' { border-radius: 0; } div#'||PRM_OBJETO||' span#'||PRM_OBJETO||'more { border-radius: 0 0 6px 0; } a#'||PRM_OBJETO||'fechar { border-radius: 0 0 0 6px; }</style>');
						END IF;

						HTP.P('<div onmousedown="event.stopPropagation();" class="dragme grafico" id="'||RTRIM(PRM_OBJETO)||'" data-top="'||WS_POSY||'" data-left="'||WS_POSX||'" style="'||WS_POSICAO||'; '||WS_GRADIENTE||'">');

						OBJ.OPCOES(WS_OBJID, WS_TP_OBJETO, '', '', PRM_SCREEN, PRM_DRILL, PRM_USUARIO => WS_USUARIO);

						WS_ALINHAMENTO_TIT := FUN.GETPROP(PRM_OBJETO,'ALIGN_TIT');
						IF WS_ALINHAMENTO_TIT = 'left' THEN
							WS_ALINHAMENTO_TIT := WS_ALINHAMENTO_TIT||'; text-indent: 14px';
						END IF; 

						IF WS_ADMIN = 'A' THEN
							IF SUBSTR(TRIM(FUN.PUT_STYLE(WS_OBJ, 'DEGRADE', WS_TIP)), 5, 1) = 'S' THEN
								HTP.P('<div class="wd_move" title="'||FUN.LANG('Clique e arraste para mover, duplo clique para ampliar.')||'" style="text-align: '||WS_ALINHAMENTO_TIT||'; padding: 4px 23px; border-radius: 7px 7px 0 0; '||FUN.PUT_STYLE(WS_OBJ, 'TIT_COLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_IT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BOLD', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_FONT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_SIZE', WS_TIP)||'" id="'||PRM_OBJETO||'_ds">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', WS_OBJ, WS_NM_OBJETO, WS_PADRAO), PRM_SCREEN)||'</div>');
							ELSE
								HTP.P('<div class="wd_move" title="'||FUN.LANG('Clique e arraste para mover, duplo clique para ampliar.')||'" style="text-align: '||WS_ALINHAMENTO_TIT||'; padding: 4px 23px; border-radius: 7px 7px 0 0; '||FUN.PUT_STYLE(WS_OBJ, 'TIT_COLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BGCOLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_IT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BOLD', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_FONT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_SIZE', WS_TIP)||'" id="'||PRM_OBJETO||'_ds">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', WS_OBJ, WS_NM_OBJETO, WS_PADRAO), PRM_SCREEN)||'</div>');
							END IF;
						ELSE
							IF SUBSTR(TRIM(FUN.PUT_STYLE(WS_OBJ, 'DEGRADE', WS_TIP)), 5, 1) = 'S' THEN
								HTP.P('<div style="padding: 4px 23px; border-radius: 7px 7px 0 0; cursor: default; text-align: center; '||FUN.PUT_STYLE(WS_OBJ, 'TIT_COLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_IT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BOLD', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_FONT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_SIZE', WS_TIP)||'" id="'||PRM_OBJETO||'_ds">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', WS_OBJ, WS_NM_OBJETO, WS_PADRAO), PRM_SCREEN)||'</div>');
							ELSE
								HTP.P('<div style="padding: 4px 23px; border-radius: 7px 7px 0 0; cursor: default; text-align: center; '||FUN.PUT_STYLE(WS_OBJ, 'TIT_COLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BGCOLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_IT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BOLD', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_FONT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_SIZE', WS_TIP)||'" id="'||PRM_OBJETO||'_ds">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', WS_OBJ, WS_NM_OBJETO, WS_PADRAO), PRM_SCREEN)||'</div>');
							END IF;
						END IF;

						HTP.P('<div class="sub" id="'||PRM_OBJETO||'_sub" style="text-align: '||WS_ALINHAMENTO_TIT||'; '||FUN.PUT_STYLE(WS_OBJ, 'TIT_COLOR', WS_TIP)||';">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', WS_OBJ, WS_SUBTITULO, WS_PADRAO), PRM_SCREEN)||'</div>');


							HTP.PRN('<ul id="'||PRM_OBJETO||'-filterlist" style="display: none;">');
								HTP.PRN(FUN.SHOW_FILTROS(WS_PARAMETROS, '', '', PRM_OBJETO, WS_CD_MICRO_VISAO, PRM_SCREEN));
							HTP.PRN('</ul>');

							HTP.P('<div style="display: none;" id="gxml_'||PRM_OBJETO||'">');
								FCL.CHAROUT(WS_PARAMETROS, WS_CD_MICRO_VISAO, WS_OBJ, PRM_SCREEN);
							HTP.P('</div>');


							HTP.P('<div id="ctmr_'||WS_OBJ||'" class="block-fusion"></div> ');

					    HTP.P('</div>');

					WHEN WS_TP_OBJETO = 'SCRIPT' THEN
						HTP.P('<div class="dragme" style="border: 1px solid #555; background: #E7E7E7; border-radius: 4px; border: 2px solid #333; '||FUN.PUT_STYLE(WS_OBJ, 'BGCOLOR', WS_TIP)||' '||FUN.PUT_STYLE(WS_OBJ, 'COLOR', WS_TIP)||' '||FUN.PUT_STYLE(WS_OBJ, 'BOLD', WS_TIP)||' '||FUN.PUT_STYLE(WS_OBJ, 'IT', WS_TIP)||' '||FUN.PUT_STYLE(WS_OBJ, 'FONT', WS_TIP)||' position: fixed; top: 40%; left: 40%; z-index: 1; text-align: center;" id="script-load">');
							HTP.P('<script type="text/javascript"></script>');
							HTP.P('<span style="font-size: 20px; font-family: tahoma; padding: 10px;" class="up" onclick="ajax(''return'', ''Programa_Execucao'', ''prm_objeto='||PRM_OBJETO||'&prm_parametros='||FUN.GETPROP(PRM_OBJETO,'parametros')||'&prm_screen=''+tela, '''', false); alerta(''feed-fixo'', respostaAjax.trim());">EXECUTAR</span>');
							HTP.P('<a class="fechar">X</a>');
						HTP.P('</div>');

					WHEN WS_TP_OBJETO = 'ORGANOGRAMA' THEN
						
						BEGIN
							SELECT CONTEUDO INTO WS_PADRAO
							FROM   PARAMETRO_USUARIO
							WHERE  CD_USUARIO = WS_USUARIO AND
								CD_PADRAO='CD_LINGUAGEM';
						EXCEPTION
							WHEN OTHERS THEN
								WS_PADRAO := 'PORTUGUESE';
						END;
											
						IF WS_ADMIN = 'A' THEN
							IF SUBSTR(TRIM(FUN.PUT_STYLE(WS_OBJ, 'DEGRADE', WS_TIP)), 5, 1) = 'S' THEN
								HTP.P('<div onmousedown="event.stopPropagation();" class="dragme grafico" id="'||RTRIM(PRM_OBJETO)||'" data-top="'||WS_POSX||'" data-left="'||WS_POSX||'" data-swipe="" style="'||WS_POSICAO||'; '||(FUN.PUT_STYLE(WS_OBJ, 'SIZE', WS_TIP))||' background: '||WS_GRADIENTE_TIPO||'-gradient('||SUBSTR(FUN.PUT_STYLE(WS_OBJ, 'TIT_BGCOLOR', WS_TIP), 18, 7)||', '||SUBSTR(FUN.PUT_STYLE(WS_OBJ, 'BGCOLOR', WS_TIP), 18, 7)||'); width: '||FUN.GETPROP(WS_OBJ, 'LARGURA')||'px; height: '||FUN.GETPROP(WS_OBJ, 'ALTURA')||'px;" ontouchstart="swipeStart('''||WS_OBJ||''', event);" ontouchmove="swipe('''||WS_OBJ||''', event);" ontouchend="swipe('''||WS_OBJ||''', event);">');
							ELSE
								HTP.P('<div onmousedown="event.stopPropagation();" class="dragme grafico" id="'||RTRIM(PRM_OBJETO)||'" data-top="'||WS_POSY||'" data-left="'||WS_POSX||'" data-swipe="" style="'||WS_POSICAO||'; '||(FUN.PUT_STYLE(WS_OBJ, 'BGCOLOR', WS_TIP))||' '||(FUN.PUT_STYLE(WS_OBJ, 'SIZE', WS_TIP))||' width: '||FUN.GETPROP(WS_OBJ, 'LARGURA')||'px; height: '||FUN.GETPROP(WS_OBJ, 'ALTURA')||'px;" ontouchstart="swipeStart('''||WS_OBJ||''', event);" ontouchmove="swipe('''||WS_OBJ||''', event);" ontouchend="swipe('''||WS_OBJ||''', event);">');
							END IF;

							IF FUN.GETPROP(PRM_OBJETO,'NO_RADIUS') <> 'N' THEN
								HTP.P('<style>div#'||PRM_OBJETO||' { border-radius: 0; } div#'||PRM_OBJETO||' span#'||PRM_OBJETO||'more { border-radius: 0 0 6px 0; } a#'||PRM_OBJETO||'fechar { border-radius: 0 0 0 6px; }</style>');
							END IF;

							HTP.P('<style>');
								HTP.P('div.orgChart tr.lines td.left { border-right: 2px solid '||FUN.GETPROP(PRM_OBJETO, 'LINHA_COLOR')||'; }');
								HTP.P('div.orgChart tr.lines td.right { border-left: 2px solid '||FUN.GETPROP(PRM_OBJETO, 'LINHA_COLOR')||'; }');
								HTP.P('div.orgChart tr.lines td.top { border-top: 3px solid '||FUN.GETPROP(PRM_OBJETO, 'LINHA_COLOR', 'ORGANOGRAMA')||'; }');
								HTP.P('div.orgChart div.node { height: '||FUN.GETPROP(PRM_OBJETO, 'ALTURA_BLOCO')||'px; width: '||FUN.GETPROP(PRM_OBJETO, 'LARGURA_BLOCO')||'px; background-color: '||FUN.GETPROP(PRM_OBJETO, 'NODE_BGCOLOR')||'; font-size: '||FUN.GETPROP(PRM_OBJETO, 'SIZE')||'; font-weight: '||FUN.GETPROP(PRM_OBJETO, 'BOLD')||'; font-style: '||FUN.GETPROP(PRM_OBJETO, 'IT')||'; font-family: '||FUN.GETPROP(PRM_OBJETO, 'FONT')||'; color: '||FUN.GETPROP(PRM_OBJETO, 'COLOR')||'; } ');
							HTP.P('</style>');
							HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJ||'more" style="max-width: 94px;">');
								HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'post'));
								HTP.P('<span class="preferencias" title="'||FUN.LANG('Propriedades')||'"></span>');
								HTP.P('<span class="lightbulb" title="'||FUN.LANG('Drills')||'"></span>');
							HTP.P('</span>');
						ELSE
							IF SUBSTR(TRIM(FUN.PUT_STYLE(WS_OBJ, 'DEGRADE', WS_TIP)), 5, 1) = 'S' THEN
								IF NVL(FUN.GETPROP(WS_OBJ,'DEGRADE_TIPO'), '%??%') = '%??%' THEN
									WS_GRADIENTE_TIPO := 'linear';
								ELSE
									WS_GRADIENTE_TIPO := FUN.GETPROP(WS_OBJ,'DEGRADE_TIPO');
								END IF;
								WS_GRADIENTE := 'background: '||WS_GRADIENTE_TIPO||'-gradient('||SUBSTR(FUN.PUT_STYLE(WS_OBJ, 'TIT_BGCOLOR', WS_TIP), 18, 7)||', '||SUBSTR(FUN.PUT_STYLE(WS_OBJ, 'BGCOLOR', WS_TIP), 18, 7)||'); ';
							ELSE
								WS_GRADIENTE := FUN.PUT_STYLE(WS_OBJ, 'BGCOLOR', WS_TIP);
							END IF;

							HTP.P('<div onmousedown="event.stopPropagation();" class="dragme grafico" id="'||RTRIM(PRM_OBJETO)||'" data-top="'||WS_POSY||'" data-left="'||WS_POSX||'" data-swipe="" ontouchstart="swipeStart('''||WS_OBJ||''', event);" ontouchmove="swipe('''||WS_OBJ||''', event);" ontouchend="swipe('''||WS_OBJ||''', event);" style="'||WS_POSICAO||'; '||WS_GRADIENTE||' width: '||FUN.GETPROP(WS_OBJ, 'LARGURA')||'px; height: '||FUN.GETPROP(WS_OBJ, 'ALTURA')||'px;">');

							IF FUN.GETPROP(PRM_OBJETO,'NO_RADIUS') <> 'N' THEN
								HTP.P('<style>div#'||PRM_OBJETO||' { border-radius: 0; } div#'||PRM_OBJETO||' span#'||PRM_OBJETO||'more { border-radius: 0 0 6px 0; } a#'||PRM_OBJETO||'fechar { border-radius: 0 0 0 6px; }</style>');
							END IF;

							HTP.P('<style>');
								HTP.P('div.orgChart tr.lines td.left { border-right: 2px solid '||FUN.GETPROP(PRM_OBJETO, 'LINHA_COLOR')||'; }');
								HTP.P('div.orgChart tr.lines td.right { border-left: 2px solid '||FUN.GETPROP(PRM_OBJETO, 'LINHA_COLOR')||'; }');
								HTP.P('div.orgChart tr.lines td.top { border-top: 3px solid '||FUN.GETPROP(PRM_OBJETO, 'LINHA_COLOR')||'; }');
								HTP.P('div.orgChart div.node { height: '||FUN.GETPROP(PRM_OBJETO, 'ALTURA_BLOCO')||'px; width: '||FUN.GETPROP(PRM_OBJETO, 'LARGURA_BLOCO')||'px; background-color: '||FUN.GETPROP(PRM_OBJETO, 'NODE_BGCOLOR')||'; font-size: '||FUN.GETPROP(PRM_OBJETO, 'SIZE')||'; font-weight: '||FUN.GETPROP(PRM_OBJETO, 'BOLD')||'; font-style: '||FUN.GETPROP(PRM_OBJETO, 'IT')||'; font-family: '||FUN.GETPROP(PRM_OBJETO, 'FONT')||'; color: '||FUN.GETPROP(PRM_OBJETO, 'COLOR')||'; } ');
							HTP.P('</style>');
							IF FUN.GETPROP(PRM_OBJETO,'NO_OPTION') <> 'S' THEN
								HTP.P('<span title="'||FUN.LANG('Op&ccedil;&otilde;es')||'" class="options closed" id="'||WS_OBJ||'more" style="max-width: 40px;">');
									HTP.P(FUN.SHOWTAG(PRM_OBJETO, 'post'));
								HTP.P('</span>');
							END IF;
						END IF;

						IF WS_ADMIN = 'A' THEN
							IF SUBSTR(TRIM(FUN.PUT_STYLE(WS_OBJ, 'DEGRADE', WS_TIP)), 5, 1) = 'S' THEN
								HTP.P('<div data-touch="0" class="wd_move" title="'||FUN.LANG('Clique e arraste para mover, duplo clique para ampliar.')||'" style="padding: 4px 23px; border-radius: 7px 7px 0 0; '||FUN.PUT_STYLE(WS_OBJ, 'TIT_COLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_IT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BOLD', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_FONT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_SIZE', WS_TIP)||'" id="'||PRM_OBJETO||'_ds">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', PRM_OBJETO, WS_NM_PONTO, WS_PADRAO), PRM_SCREEN)||'</div>');
							ELSE
								HTP.P('<div data-touch="0" class="wd_move" title="'||FUN.LANG('Clique e arraste para mover, duplo clique para ampliar.')||'" style="padding: 4px 23px; border-radius: 7px 7px 0 0; '||FUN.PUT_STYLE(WS_OBJ, 'TIT_COLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BGCOLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_IT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BOLD', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_FONT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_SIZE', WS_TIP)||'" id="'||PRM_OBJETO||'_ds">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', PRM_OBJETO, WS_NM_PONTO, WS_PADRAO), PRM_SCREEN)||'</div>');
							END IF;
						ELSE
							IF SUBSTR(TRIM(FUN.PUT_STYLE(WS_OBJ, 'DEGRADE', WS_TIP)), 5, 1) = 'S' THEN
								HTP.P('<div data-touch="0" class="wd_move" style="cursor: move; padding: 4px 23px; border-radius: 7px 7px 0 0; cursor: default; text-align: center; '||FUN.PUT_STYLE(WS_OBJ, 'TIT_COLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_IT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BOLD', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_FONT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_SIZE', WS_TIP)||'" id="'||PRM_OBJETO||'_ds">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', PRM_OBJETO, WS_NM_PONTO, WS_PADRAO), PRM_SCREEN)||'</div>');
							ELSE
								HTP.P('<div data-touch="0" class="wd_move" style="cursor: move; padding: 4px 23px; border-radius: 7px 7px 0 0; cursor: default; text-align: center; '||FUN.PUT_STYLE(WS_OBJ, 'TIT_COLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BGCOLOR', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_IT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_BOLD', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_FONT', WS_TIP)||FUN.PUT_STYLE(WS_OBJ, 'TIT_SIZE', WS_TIP)||'" id="'||PRM_OBJETO||'_ds">'||FUN.SUBPAR(FUN.UTRANSLATE('NM_OBJETO', PRM_OBJETO, WS_NM_PONTO, WS_PADRAO), PRM_SCREEN)||'</div>');
							END IF;
						END IF;

						WS_COUNT := 0;
						HTP.P('<div id="chart-container" class="block-fusion" style="'||(FUN.PUT_STYLE(WS_OBJ, 'COLOR', WS_TIP))||' '||(FUN.PUT_STYLE(WS_OBJ, 'BOLD', WS_TIP))||' '||(FUN.PUT_STYLE(WS_OBJ, 'IT', WS_TIP))||' '||(FUN.PUT_STYLE(WS_OBJ, 'FONT', WS_TIP))||' position: relative; overflow: auto; margin: 0 auto; height: calc(100% - 32px);"></div>');
						HTP.P('<div style="display: none;" name="ngxml'||PRM_OBJETO||'" id="gxml_'||PRM_OBJETO||'">');
					    HTP.P('</div>');
					    HTP.P('</div>');

					WHEN WS_TP_OBJETO = 'BROWSER' THEN
                        BEGIN
				            BRO.BROWSER(WS_OBJ, PRM_SCREEN);
				        EXCEPTION WHEN OTHERS THEN
                            HTP.P(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
				        END;
					ELSE
                        HTP.P('');
				    END CASE;
			    END IF;
		    END IF;
		END IF;

	ELSE
        
		WS_COUNT := 0;
		HTP.P('<section id="'||PRM_OBJETO||'" style="flex-wrap: wrap; order: '||PRM_POSX||'; flex-direction: '||PRM_ZINDEX||';">');
			IF WS_ADMIN = 'A' THEN
				HTP.P('<div class="submenu" onmousedown="event.stopPropagation();">');
					HTP.P('<a class="adddash" title="'||FUN.LANG('adicionar bloco')||'" onclick="dashboard('''', ''insert'', '''||PRM_OBJETO||''');">+</a>');
					HTP.P('<select onchange="dashboard(document.getElementById(''current_screen'').value, ''rowcolumn'', '''||PRM_OBJETO||''',  this.value);">');
						HTP.P('<optgroup label="'||FUN.LANG('Formato')||'"></optgroup>');
						IF PRM_ZINDEX = 'row' THEN
							HTP.P('<option value="row" selected>'||FUN.LANG('Horizontal')||'</option>');
						ELSE
							HTP.P('<option value="row">'||FUN.LANG('Horizontal')||'</option>');
						END IF;
						IF PRM_ZINDEX = 'column' THEN
							HTP.P('<option value="column" selected>'||FUN.LANG('Vertical')||'</option>');
						ELSE
							HTP.P('<option value="column">'||FUN.LANG('Vertical')||'</option>');
						END IF;
					HTP.P('</select>');
                   
                   HTP.P(FUN.EXCLUIR_DASH(PRM_OBJETO));
				HTP.P('</div>');
                
			END IF;
			FOR I IN (SELECT OBJECT_ID, POSY, POSX, ZINDEX, DECODE(PORCENTAGEM, '0', '', PORCENTAGEM) AS PORCENTAGEM FROM OBJECT_LOCATION WHERE SCREEN = PRM_OBJETO ORDER BY POSX) LOOP
              
				IF PRM_ZINDEX = 'row' THEN
				    SELECT COUNT(*) INTO WS_COUNT FROM OBJECT_LOCATION WHERE SCREEN = PRM_OBJETO;
				    WS_POSICAO := 100/WS_COUNT;
					WS_POSICAO := '0 1 '||WS_POSICAO||'%';
				ELSE
				    WS_POSICAO := '0 0 auto';
				END IF;

				HTP.P('<article id="'||I.OBJECT_ID||'" style="justify-content: '||I.POSY||'; align-items: '||I.POSY||'; flex-direction: '||I.ZINDEX||'; order: '||NVL(I.POSX, 1)||'; flex-basis: '||NVL('calc('||I.PORCENTAGEM||' - 6.4px)', 'auto')||';">');
					IF WS_ADMIN = 'A' THEN
						HTP.P('<div class="articlemenu" onmousedown="event.stopPropagation();">');
							HTP.P(FUN.EXCLUIR_DASH(I.OBJECT_ID));
							HTP.P('<select onchange="dashboard('''||PRM_OBJETO||''', ''align'', '''||I.OBJECT_ID||''', this.value);">');
								HTP.P('<optgroup label="'||FUN.LANG('Alinhamento')||'"></optgroup>');
								IF I.POSY = 'flex-start' THEN
								    HTP.P('<option value="flex-start" selected>'||FUN.LANG('In&iacute;cio')||'</option>');
								ELSE
								    HTP.P('<option value="flex-start">'||FUN.LANG('In&iacute;cio')||'</option>');
								END IF;
								IF I.POSY = 'flex-end' THEN
								    HTP.P('<option value="flex-end" selected>'||FUN.LANG('Fim')||'</option>');
								ELSE
								    HTP.P('<option value="flex-end">'||FUN.LANG('Fim')||'</option>');
								END IF;
								IF I.POSY = 'center' THEN
								    HTP.P('<option value="center" selected>'||FUN.LANG('Centro')||'</option>');
								ELSE
								    HTP.P('<option value="center">'||FUN.LANG('Centro')||'</option>');
								END IF;
								IF I.POSY = 'inherit' THEN
								    HTP.P('<option value="inherit" selected>'||FUN.LANG('Todo')||'</option>');
								ELSE
								    HTP.P('<option value="inherit">'||FUN.LANG('Todo')||'</option>');
								END IF;
							HTP.P('</select>');
							HTP.P('<select onchange="dashboard('''||PRM_OBJETO||''', ''rowcolumn'', '''||I.OBJECT_ID||''', this.value);">');
								HTP.P('<optgroup label="Formato"></optgroup>');
								IF I.ZINDEX = 'row' THEN
									HTP.P('<option value="row" selected>'||FUN.LANG('Horizontal')||'</option>');
								ELSE
									HTP.P('<option value="row">'||FUN.LANG('Horizontal')||'</option>');
								END IF;
								IF I.ZINDEX = 'column' THEN
									HTP.P('<option value="column" selected>'||FUN.LANG('Vertical')||'</option>');
								ELSE
									HTP.P('<option value="column">'||FUN.LANG('Vertical')||'</option>');
								END IF;
							HTP.P('</select>');
							HTP.P('<input onkeypress="if(event.which == ''13''){ this.blur(); }" onblur="dashboard('''||PRM_OBJETO||''', ''porcentagem'', '''||I.OBJECT_ID||''', this.value);" value="'||I.PORCENTAGEM||'" placeholder="'||FUN.LANG('medida')||'" title="'||FUN.LANG('MEDIDA')||'">');
							HTP.P('<input id="'||I.OBJECT_ID||'ordem" onkeypress="if(event.which == ''13''){ this.blur(); }" onblur="dashboard('''||PRM_OBJETO||''', ''ordem'', '''||I.OBJECT_ID||''', this.value);" value="'||NVL(I.POSX, 1)||'" placeholder="'||FUN.LANG('ordem')||'" title="'||FUN.LANG('ORDEM')||'">');

                            HTP.P('<img title="'||FUN.LANG('Inserir objeto')||'" src="dwu.fcl.download?arquivo=folder.png" onclick="closeSideBar(''attriblist''); document.getElementById(''attriblist'').classList.toggle(''open''); ajax(''list'', ''lista_objetos'', '''', false, ''attriblist'');">');
						HTP.P('</div>');
					END IF;

					FOR A IN (SELECT OBJECT_ID, POSY, POSX, ZINDEX FROM OBJECT_LOCATION WHERE TRIM(SCREEN) = TRIM(I.OBJECT_ID) AND OBJECT_ID NOT LIKE 'ARTICLE%' ORDER BY POSX) LOOP
						OBJ.SHOW_OBJETO(A.OBJECT_ID, A.POSX, A.POSY, '', PRM_ZINDEX => A.ZINDEX, PRM_DASHBOARD => 'true', PRM_SCREEN => PRM_SCREEN);
					END LOOP;

				HTP.P('</article>');
			END LOOP;

		HTP.P('</section>');
	END IF;

	EXCEPTION 
		WHEN WS_NOUSER THEN
			HTP.P('Sem permiss&atilde;o!');
		WHEN OTHERS THEN
			INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SHOW_OBJETO', WS_USUARIO, 'ERRO');
			COMMIT;	
			HTP.P('</div>');
END SHOW_OBJETO;

END OBJ;