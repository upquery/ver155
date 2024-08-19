set scan off
create or replace PACKAGE BODY BRO  IS

    PROCEDURE BROWSER ( PRM_OBJETO VARCHAR2 DEFAULT NULL,
                        PRM_SCREEN VARCHAR2 DEFAULT NULL ) AS

		CURSOR CRS_MICRO_DATA IS
		SELECT NM_TABELA AS TABELA, NVL((SELECT NM_OBJETO FROM OBJETOS WHERE CD_OBJETO = PRM_OBJETO), DS_MICRO_VISAO) AS DESCRICAO
		FROM MICRO_DATA WHERE NM_MICRO_DATA = PRM_OBJETO;

		WS_MICRO_DATA CRS_MICRO_DATA%ROWTYPE;
		
		WS_DATA_COLUNA  VARCHAR2(800);
		WS_CHAVE        VARCHAR2(800);
		WS_EDIT         BOOLEAN := TRUE;
		WS_LIGACAO      VARCHAR2(80);
		WS_COUNT        NUMBER := 0;
		WS_LIGACLASS    VARCHAR2(500);
		WS_COUNTCOLUNA  NUMBER;
		WS_MSG			VARCHAR2(100);
		WS_EXISTCHAVE   NUMBER;
		WS_FIRST        VARCHAR2(100);
		WS_USUARIO      VARCHAR2(80);
		WS_ADMIN        VARCHAR2(100);

	BEGIN

	    WS_USUARIO := GBL.GETUSUARIO;
	    WS_ADMIN   := GBL.GETNIVEL;

	    OPEN CRS_MICRO_DATA;
		FETCH CRS_MICRO_DATA INTO WS_MICRO_DATA;
		CLOSE CRS_MICRO_DATA;
		
		HTP.P('<div id="data_list_menu" data-top="" data-left="" data-height="'||FUN.GETPROP(PRM_OBJETO, 'ALTURA', 'DEFAULT', WS_USUARIO)||'" data-width="'||FUN.GETPROP(PRM_OBJETO, 'LARGURA', 'DEFAULT', WS_USUARIO)||'" style="height: '||FUN.GETPROP(PRM_OBJETO, 'ALTURA', 'DEFAULT', WS_USUARIO)||'px; width: '||FUN.GETPROP(PRM_OBJETO, 'LARGURA', 'DEFAULT', WS_USUARIO)||'px;" onmouseleave="this.classList.remove(''moving'');" onmousedown="this.classList.add(''moving''); this.setAttribute(''data-top'', event.layerY); this.setAttribute(''data-left'', event.layerX);" onmouseup="this.classList.remove(''moving'');">');
			HTP.P('<div id="editb" onmouseleave="resizeBrowser(this, '''||PRM_OBJETO||''');"></div>'); 
	        HTP.P('<div id="browserbuttons"></div>');
		HTP.P('</div>');
        
		HTP.P('<div id="data_list" class="'||PRM_OBJETO||'" data-tabela="'||WS_MICRO_DATA.TABELA||'">');

		HTP.P('<h2 onclick="/*toggleFullScreen();*/">'||FUN.SUBPAR(WS_MICRO_DATA.DESCRICAO, PRM_SCREEN)||'</h2>');

		SELECT COUNT(*) INTO WS_COUNTCOLUNA FROM DATA_COLUNA WHERE CD_MICRO_DATA = PRM_OBJETO;
			IF WS_COUNTCOLUNA > 0 THEN
				SELECT TIPO_INPUT INTO WS_LIGACAO FROM (SELECT TIPO_INPUT FROM DATA_COLUNA WHERE CD_MICRO_DATA = PRM_OBJETO ORDER BY ST_CHAVE DESC) WHERE ROWNUM = 1;
			END IF;

		SELECT COUNT(ST_CHAVE) INTO WS_EXISTCHAVE FROM DATA_COLUNA WHERE CD_MICRO_DATA = PRM_OBJETO AND ST_CHAVE = '1' OR ST_CHAVE = 1;

        HTP.P('<div class="menu '||WS_LIGACAO||'">');
			
		IF WS_EXISTCHAVE <> 0 THEN

			SELECT COUNT(*) INTO WS_COUNT FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJETO AND CD_PROP = 'PERMISSAOAD' AND WS_USUARIO IN (SELECT * FROM TABLE((FUN.VPIPE(PROPRIEDADE))));

            IF WS_COUNT = 0 THEN
			
                HTP.P('<a class="buttonbrowser" title="'||FUN.LANG('adicionar linha')||'" onclick="browserEvent(event, '''||PRM_OBJETO||''', ''new'');"><svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 491.86 491.86" style="enable-background:new 0 0 491.86 491.86;" xml:space="preserve"> <g> <g> <path d="M465.167,211.614H280.245V26.691c0-8.424-11.439-26.69-34.316-26.69s-34.316,18.267-34.316,26.69v184.924H26.69 C18.267,211.614,0,223.053,0,245.929s18.267,34.316,26.69,34.316h184.924v184.924c0,8.422,11.438,26.69,34.316,26.69 s34.316-18.268,34.316-26.69V280.245H465.17c8.422,0,26.69-11.438,26.69-34.316S473.59,211.614,465.167,211.614z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg></a>');
		    
            END IF;
		END IF;
					    
            IF WS_ADMIN = 'A' THEN
                HTP.P('<a class="buttonbrowser" title="'||FUN.LANG('alterar colunas')||'" onclick="browserEvent(event, '''||PRM_OBJETO||''', ''colunas'');"><svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"width="433.5px" height="433.5px" viewBox="0 0 433.5 433.5" style="enable-background:new 0 0 433.5 433.5;" xml:space="preserve"> <g> <g id="view-column"> <path d="M153,382.5h127.5V51H153V382.5z M0,382.5h127.5V51H0V382.5z M306,51v331.5h127.5V51H306z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg></a>');
            END IF;
            
            IF WS_ADMIN = 'A' THEN
                HTP.P('<a class="buttonbrowser" title="'||FUN.LANG('propriedades')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||PRM_OBJETO||''');"><svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 268.765 268.765" style="enable-background:new 0 0 268.765 268.765;" xml:space="preserve"> <g id="Settings"> <g> <path style="fill-rule:evenodd;clip-rule:evenodd;" d="M267.92,119.461c-0.425-3.778-4.83-6.617-8.639-6.617 c-12.315,0-23.243-7.231-27.826-18.414c-4.682-11.454-1.663-24.812,7.515-33.231c2.889-2.641,3.24-7.062,0.817-10.133 c-6.303-8.004-13.467-15.234-21.289-21.5c-3.063-2.458-7.557-2.116-10.213,0.825c-8.01,8.871-22.398,12.168-33.516,7.529 c-11.57-4.867-18.866-16.591-18.152-29.176c0.235-3.953-2.654-7.39-6.595-7.849c-10.038-1.161-20.164-1.197-30.232-0.08 c-3.896,0.43-6.785,3.786-6.654,7.689c0.438,12.461-6.946,23.98-18.401,28.672c-10.985,4.487-25.272,1.218-33.266-7.574 c-2.642-2.896-7.063-3.252-10.141-0.853c-8.054,6.319-15.379,13.555-21.74,21.493c-2.481,3.086-2.116,7.559,0.802,10.214 c9.353,8.47,12.373,21.944,7.514,33.53c-4.639,11.046-16.109,18.165-29.24,18.165c-4.261-0.137-7.296,2.723-7.762,6.597 c-1.182,10.096-1.196,20.383-0.058,30.561c0.422,3.794,4.961,6.608,8.812,6.608c11.702-0.299,22.937,6.946,27.65,18.415 c4.698,11.454,1.678,24.804-7.514,33.23c-2.875,2.641-3.24,7.055-0.817,10.126c6.244,7.953,13.409,15.19,21.259,21.508 c3.079,2.481,7.559,2.131,10.228-0.81c8.04-8.893,22.427-12.184,33.501-7.536c11.599,4.852,18.895,16.575,18.181,29.167 c-0.233,3.955,2.67,7.398,6.595,7.85c5.135,0.599,10.301,0.898,15.481,0.898c4.917,0,9.835-0.27,14.752-0.817 c3.897-0.43,6.784-3.786,6.653-7.696c-0.451-12.454,6.946-23.973,18.386-28.657c11.059-4.517,25.286-1.211,33.281,7.572 c2.657,2.89,7.047,3.239,10.142,0.848c8.039-6.304,15.349-13.534,21.74-21.494c2.48-3.079,2.13-7.559-0.803-10.213 c-9.353-8.47-12.388-21.946-7.529-33.524c4.568-10.899,15.612-18.217,27.491-18.217l1.662,0.043 c3.853,0.313,7.398-2.655,7.865-6.588C269.044,139.917,269.058,129.639,267.92,119.461z M134.595,179.491 c-24.718,0-44.824-20.106-44.824-44.824c0-24.717,20.106-44.824,44.824-44.824c24.717,0,44.823,20.107,44.823,44.824 C179.418,159.385,159.312,179.491,134.595,179.491z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
            END IF;
            
			
			SELECT COUNT(*) INTO WS_COUNT FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_OBJETO AND CD_PROP = 'PERMISSAONOFILTER' AND WS_USUARIO IN (SELECT * FROM TABLE((FUN.VPIPE(PROPRIEDADE))));

            IF WS_COUNT = 0 OR WS_ADMIN = 'A' THEN
			
                HTP.P('<a class="buttonbrowser" title="'||FUN.LANG('alterar filtros')||'" onclick="browserEvent(event, '''||PRM_OBJETO||''', ''filtros'', '''||WS_MICRO_DATA.TABELA||''');"><svg style="stroke-width: 2px; stroke: #FFF;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="56.805px" height="56.805px" viewBox="0 0 56.805 56.805" style="enable-background:new 0 0 56.805 56.805;" xml:space="preserve"> <g> <g id="_x32_7"> <g> <path d="M56.582,4.352c-0.452-1.092-1.505-1.796-2.685-1.796H2.908c-1.18,0-2.233,0.704-2.685,1.796 c-0.451,1.091-0.204,2.336,0.63,3.171l20.177,20.21V53.02c0,0.681,0.55,1.229,1.229,1.229c0.68,0,1.229-0.549,1.229-1.229V27.223 c0-0.327-0.13-0.64-0.36-0.87L2.591,5.782c-0.184-0.185-0.14-0.385-0.098-0.487C2.537,5.19,2.646,5.019,2.908,5.019h50.99 c0.26,0,0.37,0.173,0.414,0.276c0.042,0.103,0.086,0.303-0.099,0.487L33.679,26.353c-0.23,0.23-0.36,0.543-0.36,0.87v18.412 c0,0.681,0.55,1.229,1.229,1.229c0.681,0,1.229-0.55,1.229-1.229V27.732l20.177-20.21C56.785,6.688,57.033,5.443,56.582,4.352z"></path> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg></a>');
            
            END IF;
			
			HTP.P('<a class="buttonbrowser" title="'||FUN.LANG('alterar destaques')||'" onclick="browserEvent(event, '''||PRM_OBJETO||''', ''destaques'', '''||WS_MICRO_DATA.TABELA||''');"><svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 19.481 19.481" xmlns:xlink="http://www.w3.org/1999/xlink" enable-background="new 0 0 19.481 19.481"> <g> <path d="m10.201,.758l2.478,5.865 6.344,.545c0.44,0.038 0.619,0.587 0.285,0.876l-4.812,4.169 1.442,6.202c0.1,0.431-0.367,0.77-0.745,0.541l-5.452-3.288-5.452,3.288c-0.379,0.228-0.845-0.111-0.745-0.541l1.442-6.202-4.813-4.17c-0.334-0.289-0.156-0.838 0.285-0.876l6.344-.545 2.478-5.864c0.172-0.408 0.749-0.408 0.921,0z"></path> </g> </svg></a>');

			HTP.P('<a id="excel-browser" class="buttonbrowser" onclick="toexcel('''||PRM_OBJETO||''');" title="exportar relat&oacute;rio">');
				HTP.P('<svg style="margin: 1px 0; width: auto; height: 22px; pointer-events: none;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 512 512" style="enable-background:new 0 0 512 512;" xml:space="preserve"> <path style="fill:#ECEFF1;" d="M496,432.011H272c-8.832,0-16-7.168-16-16s0-311.168,0-320s7.168-16,16-16h224 c8.832,0,16,7.168,16,16v320C512,424.843,504.832,432.011,496,432.011z"/> <g> <path style="fill:#388E3C;" d="M336,176.011h-64c-8.832,0-16-7.168-16-16s7.168-16,16-16h64c8.832,0,16,7.168,16,16 S344.832,176.011,336,176.011z"/> <path style="fill:#388E3C;" d="M336,240.011h-64c-8.832,0-16-7.168-16-16s7.168-16,16-16h64c8.832,0,16,7.168,16,16 S344.832,240.011,336,240.011z"/> <path style="fill:#388E3C;" d="M336,304.011h-64c-8.832,0-16-7.168-16-16s7.168-16,16-16h64c8.832,0,16,7.168,16,16 S344.832,304.011,336,304.011z"/> <path style="fill:#388E3C;" d="M336,368.011h-64c-8.832,0-16-7.168-16-16s7.168-16,16-16h64c8.832,0,16,7.168,16,16 S344.832,368.011,336,368.011z"/> <path style="fill:#388E3C;" d="M432,176.011h-32c-8.832,0-16-7.168-16-16s7.168-16,16-16h32c8.832,0,16,7.168,16,16 S440.832,176.011,432,176.011z"/> <path style="fill:#388E3C;" d="M432,240.011h-32c-8.832,0-16-7.168-16-16s7.168-16,16-16h32c8.832,0,16,7.168,16,16 S440.832,240.011,432,240.011z"/> <path style="fill:#388E3C;" d="M432,304.011h-32c-8.832,0-16-7.168-16-16s7.168-16,16-16h32c8.832,0,16,7.168,16,16 S440.832,304.011,432,304.011z"/> <path style="fill:#388E3C;" d="M432,368.011h-32c-8.832,0-16-7.168-16-16s7.168-16,16-16h32c8.832,0,16,7.168,16,16 S440.832,368.011,432,368.011z"/> </g> <path style="fill:#2E7D32;" d="M282.208,19.691c-3.648-3.04-8.544-4.352-13.152-3.392l-256,48C5.472,65.707,0,72.299,0,80.011v352 c0,7.68,5.472,14.304,13.056,15.712l256,48c0.96,0.192,1.952,0.288,2.944,0.288c3.712,0,7.328-1.28,10.208-3.68 c3.68-3.04,5.792-7.584,5.792-12.32v-448C288,27.243,285.888,22.731,282.208,19.691z"/> <path style="fill:#FAFAFA;" d="M220.032,309.483l-50.592-57.824l51.168-65.792c5.44-6.976,4.16-17.024-2.784-22.464 c-6.944-5.44-16.992-4.16-22.464,2.784l-47.392,60.928l-39.936-45.632c-5.856-6.72-15.968-7.328-22.56-1.504 c-6.656,5.824-7.328,15.936-1.504,22.56l44,50.304L83.36,310.187c-5.44,6.976-4.16,17.024,2.784,22.464 c2.944,2.272,6.432,3.36,9.856,3.36c4.768,0,9.472-2.112,12.64-6.176l40.8-52.48l46.528,53.152 c3.168,3.648,7.584,5.504,12.032,5.504c3.744,0,7.488-1.312,10.528-3.968C225.184,326.219,225.856,316.107,220.032,309.483z"/> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
            HTP.P('</a>');

            HTP.P('<span id="bro-menu">');
			    BRO.MENU(PRM_OBJETO);
			HTP.P('</span>');
 
			HTP.P('<select id="browser-condicao" onchange="var campo = document.getElementById(''data-valor''); if(this.value == ''nulo'' || this.value == ''nnulo''){ campo.value = ''0''; campo.parentNode.classList.add(''nulo''); } else { campo.value = ''''; campo.parentNode.classList.remove(''nulo''); }">');
			    HTP.P('<option value="igual">'||FUN.LANG('Igual')||'</option>');
                HTP.P('<option value="maior">'||FUN.LANG('Igual ou Maior')||'</option>');
                HTP.P('<option selected value="semelhante">'||FUN.LANG('Semelhante')||'</option>');
                HTP.P('<option value="diferente">'||FUN.LANG('Diferente')||'</option>');
				HTP.P('<option value="nulo">'||FUN.LANG('Nulo')||'</option>');
				HTP.P('<option value="nnulo">'||FUN.LANG('N&atilde;o Nulo')||'</option>');
			HTP.P('</select>');

			SELECT CD_COLUNA INTO WS_FIRST FROM (SELECT CD_COLUNA FROM DATA_COLUNA WHERE CD_MICRO_DATA = PRM_OBJETO ORDER BY ST_CHAVE DESC) WHERE ROWNUM = 1;
         
			FCL.FAKEOPTION(WS_FIRST, 'Lista de colunas', '', 'lista-ligacao-browser', 'N', 'N', WS_MICRO_DATA.TABELA, PRM_ADICIONAL => PRM_OBJETO);
			HTP.P('<input type="text" id="data-valor" onkeypress="if(event.which == 13){ this.nextElementSibling.click(); }" style="padding: 2px 26px 0 2px; width: 140px;">');
			HTP.P('<img onclick="browserSearch('''');" title="pesquisar" src="'||FUN.R_GIF('lupe', 'PNG')||'" />');
		
		HTP.P('</div>');
		
		
			
		HTP.P('<div class="menu right">');
			HTP.P('<div class="arrows">');
				HTP.P('<a class="backstart" onclick="if(parseInt(document.getElementById(''browser-page'').getAttribute(''data-pagina'')) > 1){ browserSearch(''<<'', document.getElementById(''ajax'').firstElementChild.className); } else { alerta(''feed-fixo'', '''||FUN.LANG('Primeira p&aacute;gina')||'!''); }" title="'||FUN.LANG('Voltar ao in&iacute;cio')||'"><img src="'||FUN.R_GIF('seta', 'PNG')||'" /><img src="'||FUN.R_GIF('seta', 'PNG')||'" /></a>');
				HTP.P('<a class="backpage" onclick="if(parseInt(document.getElementById(''browser-page'').getAttribute(''data-pagina'')) > 1){ browserSearch(''<'', document.getElementById(''ajax'').firstElementChild.className); } else { alerta(''feed-fixo'', '''||FUN.LANG('Primeira p&aacute;gina')||'!''); }" title="'||FUN.LANG('Voltar uma p&aacute;gina')||'"><img src="'||FUN.R_GIF('seta', 'PNG')||'" /></a>');
				HTP.P('<select id="linhas" type="number" title="numero de linhas" onchange="if(document.getElementById(''ajax'').firstElementChild){ var origem = document.getElementById(''ajax'').firstElementChild.className; } else { var origem = 0; } ajax(''fly'', ''alter_attrib'', ''prm_objeto='||PRM_OBJETO||'&prm_prop=LINHAS&prm_value=''+this.value+''&prm_usuario='||WS_USUARIO||''', true); browserSearch(''<<'', origem);"/>');
                    HTP.P('<option value="50">50 linhas</option>');
                    IF FUN.GETPROP(PRM_OBJETO, 'LINHAS', 'DEFAULT', WS_USUARIO) = '100' THEN
					    HTP.P('<option value="100" selected>100 linhas</option>');
                    ELSE
                        HTP.P('<option value="100">100 linhas</option>');
                    END IF;
					IF FUN.GETPROP(PRM_OBJETO, 'LINHAS', 'DEFAULT', WS_USUARIO) = '200' THEN
					    HTP.P('<option value="200" selected>200 linhas</option>');
                    ELSE
                        HTP.P('<option value="200">200 linhas</option>');
                    END IF;
					IF FUN.GETPROP(PRM_OBJETO, 'LINHAS', 'DEFAULT', WS_USUARIO) = '400' THEN
					    HTP.P('<option value="400" selected>400 linhas</option>');
                    ELSE
                        HTP.P('<option value="400">400 linhas</option>');
                    END IF;
				HTP.P('</select>');
				HTP.P('<a onclick="if(document.getElementById(''browser-page'').getAttribute(''data-pagina'') != document.getElementById(''browser-page'').className){ if(document.getElementById(''ajax'').lastElementChild){ var origem = document.getElementById(''ajax'').lastElementChild.className; } else { var origem = 0; } browserSearch(''>'', origem); } else { alerta(''feed-fixo'', '''||FUN.LANG('&Uacute;ltima p&aacute;gina')||'!''); }"style="transform: rotate(-90deg); margin: 3px 5px;" title="'||FUN.LANG('Avan&ccedil;ar uma p&aacute;gina')||'"><img src="'||FUN.R_GIF('seta', 'PNG')||'" /></a>');
				HTP.P('<a onclick="if(document.getElementById(''browser-page'').getAttribute(''data-pagina'') != document.getElementById(''browser-page'').className){ if(document.getElementById(''ajax'').lastElementChild){ var origem = document.getElementById(''ajax'').lastElementChild.className; } else { var origem = 0; } browserSearch(''>>'', origem); } else { alerta(''feed-fixo'', '''||FUN.LANG('&Uacute;ltima p&aacute;gina')||'!''); }"style="transform: rotate(-90deg); margin: 0 5px;" title="'||FUN.LANG('Avan&ccedil;ar para a &uacute;ltima p&aacute;gina')||'"><img src="'||FUN.R_GIF('seta', 'PNG')||'" /><img src="'||FUN.R_GIF('seta', 'PNG')||'" /></a>');
			HTP.P('</div>');

            HTP.P('<input class="font-size" value="'||FUN.GETPROP(PRM_OBJETO, 'SIZE', 'DEFAULT', WS_USUARIO)||'" type="range" step="1" min="10" max="20" onchange="ajax(''fly'', ''alter_attrib'', ''prm_objeto='||PRM_OBJETO||'&prm_prop=SIZE&prm_value=''+this.value+''&prm_usuario='||WS_USUARIO||''', true);" oninput="document.querySelector(''.header'').style.setProperty(''font-size'', this.value+''px''); document.querySelector(''.corpo'').style.setProperty(''font-size'', this.value+''px''); /*this.nextElementSibling.value = this.value+''px'';*/"/>');
            HTP.P('<input class="font-size-number" type="text" readonly value="14px"/>');

		HTP.P('</div>');


		HTP.P('<div class="menu" id="filtros-acumulados"></div>');
			BEGIN
								
				IF WS_COUNTCOLUNA > 0 THEN
					BRO.MAIN_DATA(PRM_OBJETO, WS_DATA_COLUNA, WS_MICRO_DATA.TABELA,PRM_SCREEN, '');
				ELSE
					IF WS_ADMIN = 'A' THEN
						HTP.P('<div id="msgtexto">');
							HTP.P('<tr class="msgtexto">');
								HTP.P('<td>Nenhuma coluna declarada!</td>');
							HTP.P('</tr>');
						HTP.P('</div>');
					END IF;
				END IF;
			END;

		HTP.P('</div>');
	EXCEPTION WHEN OTHERS THEN
		IF WS_ADMIN = 'A' THEN
			HTP.P(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
		END IF;

	END BROWSER;

	PROCEDURE BROWSERBUTTONS  ( PRM_TIPO VARCHAR2 DEFAULT NULL,
	                            PRM_VISAO VARCHAR2 DEFAULT NULL,
	                            PRM_CHAVE VARCHAR2 DEFAULT NULL ) AS
	
	    WS_COUNT_EX NUMBER;
		WS_COUNT_ED NUMBER;
		WS_COUNT_AD NUMBER;
		WS_USUARIO  VARCHAR2(80);

	BEGIN

	    WS_USUARIO := GBL.GETUSUARIO;
	
	    SELECT COUNT(*) INTO WS_COUNT_EX FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_VISAO AND CD_PROP = 'PERMISSAOEX' AND WS_USUARIO IN (SELECT * FROM TABLE((FUN.VPIPE(PROPRIEDADE))));
	    SELECT COUNT(*) INTO WS_COUNT_ED FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_VISAO AND CD_PROP = 'PERMISSAOED' AND WS_USUARIO IN (SELECT * FROM TABLE((FUN.VPIPE(PROPRIEDADE))));
	    SELECT COUNT(*) INTO WS_COUNT_AD FROM OBJECT_ATTRIB WHERE CD_OBJECT = PRM_VISAO AND CD_PROP = 'PERMISSAOAD' AND WS_USUARIO IN (SELECT * FROM TABLE((FUN.VPIPE(PROPRIEDADE))));


		    CASE PRM_TIPO
				WHEN 'update' THEN
					
					IF WS_COUNT_ED = 0 THEN
					    HTP.P('<a class="link ac1" title="ctrl + ENTER" onclick="save(''browseredit''); if(document.querySelector(''.selectedbline'')){ document.querySelector(''.selectedbline'').classList.remove(''selectedbline''); } selectedb = '''';">'||FUN.LANG('SALVAR')||'</a>');
					END IF;
					
					IF WS_COUNT_EX = 0 THEN
					    HTP.P('<a class="link ac2" style="background: #DD2222; color: #FFFFFF;" onclick="var dis = this; curtain(); if(confirm(''Tem certeza que gostaria de excluir a linha?'')){ loading(); call(''browserExclude'', ''prm_chave=''+document.getElementById(''browser-chave-valores'').value+''&prm_campo=''+document.getElementById(''browser-campos'').value+''&prm_visao='||PRM_VISAO||''', ''bro'').then(function(resposta){ loading(); if(resposta.indexOf(''OK'') != -1){ alerta(''feed-fixo'', TR_EX); browserSearch(''BUSCA''); browserMenu(dis.parentNode.parentNode); } else { alerta(''feed-fixo'', resposta.replace(''ERROR: '', '''')); } }); }">'||FUN.LANG('EXCLUIR')||'</a>');
		            END IF;
					
				WHEN 'insert' THEN
		            IF WS_COUNT_AD = 0 THEN
					    HTP.P('<a class="link ac1" onclick="save(''browseradd''); if(document.querySelector(''.selectedbline'')){ document.querySelector(''.selectedbline'').classList.remove(''selectedbline''); } selectedb = '''';">'||FUN.LANG('ADICIONAR')||'</a>');
	                END IF;
			ELSE
		        HTP.P('');
		    END CASE;

        HTP.P('<a class="link ac3" onclick="curtain(); selectedb = ''''; browserMenu(this.parentNode.parentNode);">'||FUN.LANG('FECHAR')||'</a>');

	END BROWSERBUTTONS;


	PROCEDURE BROWSEREDIT ( PRM_OBJ    VARCHAR2 DEFAULT NULL,
	                        PRM_CHAVE  VARCHAR2 DEFAULT NULL,
							PRM_CAMPO  VARCHAR2 DEFAULT NULL,
                            PRM_TABELA VARCHAR2 DEFAULT NULL ) AS


	    CURSOR CRS_DADOS IS

		SELECT CD_COLUNA, NM_ROTULO, NM_MASCARA, ST_CHAVE, ST_DEFAULT, CD_LIGACAO, FORMULA, ST_ALINHAMENTO, DS_ALINHAMENTO, TIPO_INPUT, COLUMN_ID, TAMANHO, ST_BRANCO, DATA_LENGTH, NVL(ORDEM, 99) AS ORDEM, NVL(PERMISSAO, 'W') AS PERMISSAO, ST_INVISIVEL, VIRTUAL_COLUMN
        FROM DATA_COLUNA, ALL_TAB_COLS
		WHERE CD_MICRO_DATA = TRIM(PRM_OBJ)
        AND COLUMN_NAME = CD_COLUNA AND
        TRIM(TABLE_NAME) = TRIM(PRM_TABELA)
		ORDER BY COLUMN_ID, ST_CHAVE, ORDEM, PERMISSAO;
		
	    WS_DADO CRS_DADOS%ROWTYPE;

		WS_SQL  VARCHAR2(8000);
		
		PRM_LINHAS DBMS_SQL.VARCHAR2_TABLE;

		WS_COUNT         NUMBER := 0;
		WS_TAB           NUMBER := 0;
		WS_NOTFOUND      EXCEPTION;
		WS_MASCARA       VARCHAR2(400) := '';
		WS_LINHAS        NUMBER;
		WS_LISTA         VARCHAR2(4000);
		WS_CURSOR	     INTEGER;
		WS_VALOR         VARCHAR2(4000) := '';
		WS_READ          VARCHAR2(4000);
		WS_EVENT         VARCHAR2(4000);
        WS_CHAVE         NUMBER;
        WS_COUNTER       NUMBER;
        WS_INVISIVEL     VARCHAR2(800);
        WS_OBRIGATORIO   VARCHAR2(20) := '';
        WS_COUNT_PER     NUMBER;
		WS_HTML_D        VARCHAR2(4000);
		WS_HTML_V        VARCHAR2(4000);
		WS_NLS           VARCHAR2(20);
		WS_TAMANHO		 NUMBER;
        WS_USUARIO       VARCHAR2(80);
	BEGIN

	    WS_USUARIO := GBL.GETUSUARIO;
	
	    SELECT VALUE INTO WS_NLS FROM NLS_DATABASE_PARAMETERS WHERE  PARAMETER = 'NLS_DATE_FORMAT';
	
	    
	    IF LENGTH(PRM_CHAVE) > 0 THEN

		    BRO.GET_LINHA(PRM_TABELA, PRM_CHAVE, PRM_CAMPO, PRM_LINHAS, PRM_OBJ);
			
			IF  SUBSTR(PRM_LINHAS(1),1,10) = '%ERR%-UPQ-' THEN
				RAISE WS_NOTFOUND;
		    END IF;

			HTP.P('<input id="browser-chave-valores" type="hidden" value="'||TRIM(PRM_CHAVE)||'"/>');
			
		ELSE
		
            HTP.P('<input id="browser-chave-valores" type="hidden" value=""/>');
			
        END IF;

		HTP.P('<input id="browser-tabela" type="hidden" value="'||PRM_OBJ||'"/>');
		HTP.P('<input id="browser-campos" type="hidden" value="'||PRM_CAMPO||'"/>');
		
	    HTP.P('<ul id="browseredit">');

			OPEN CRS_DADOS;
				LOOP
					FETCH CRS_DADOS INTO WS_DADO;
					EXIT WHEN CRS_DADOS%NOTFOUND;

                    BEGIN

					WS_COUNT := WS_COUNT+1;

                    
	                IF LENGTH(PRM_CHAVE) > 0 THEN

		                WS_VALOR := PRM_LINHAS(WS_COUNT);
		            ELSE

                        WS_VALOR := FUN.XEXEC(WS_DADO.ST_DEFAULT, '');

                    END IF;
					
					IF WS_DADO.TIPO_INPUT = 'data' OR WS_DADO.TIPO_INPUT = 'datatime' THEN
					
						BEGIN
							WS_VALOR := TO_CHAR(TO_DATE(WS_VALOR, WS_NLS), 'DD/MM/YYYY HH24:MI');
						EXCEPTION WHEN OTHERS THEN
						    WS_VALOR := WS_VALOR;
						END;
					END IF;
                    
                    SELECT COUNT(*) INTO WS_COUNT_PER FROM TABLE((FUN.VPIPE(WS_DADO.PERMISSAO)));
                    IF WS_DADO.PERMISSAO = 'R' THEN
                        WS_READ := ' disabled ';
                    ELSE
	                    IF WS_COUNT_PER <> 0 AND WS_DADO.PERMISSAO <> 'W' THEN
	                        SELECT COUNT(*) INTO WS_COUNT_PER FROM TABLE((FUN.VPIPE(WS_DADO.PERMISSAO))) WHERE COLUMN_VALUE = WS_USUARIO;
						    IF WS_COUNT_PER = 0 THEN
						        WS_READ := ' disabled ';
						    ELSE
						        WS_READ := ' ';
						    END IF;
						ELSE
						    WS_READ := ' ';
						END IF;
				    END IF;

				    
                    WS_CHAVE := WS_DADO.ST_CHAVE;
                    
                    IF (WS_DADO.ST_INVISIVEL = 'S' OR WS_DADO.ST_INVISIVEL = 'B') OR (WS_DADO.VIRTUAL_COLUMN = 'YES') THEN
                        WS_INVISIVEL := 'display: none;';
						WS_TAB := '';
                    ELSE
					    WS_TAB := WS_DADO.ORDEM;
                        WS_INVISIVEL := '';
                    END IF;
                    
                    IF INSTR(PRM_CAMPO, WS_DADO.CD_COLUNA) > 0 OR WS_DADO.ST_BRANCO = '1' THEN
                        WS_OBRIGATORIO := 'data-obrigatorio="*"';
                    ELSE
                        WS_OBRIGATORIO := '';
                    END IF;

					IF LENGTH(PRM_CHAVE) > 0 THEN
					    
					    IF WS_DADO.TIPO_INPUT = 'data' THEN
                            BEGIN
							    WS_HTML_D := TRIM(SUBSTR(WS_VALOR, 1, LENGTH(WS_VALOR)-5));
							    WS_HTML_V := TRIM(SUBSTR(WS_VALOR, 1, LENGTH(WS_VALOR)-5));
							EXCEPTION WHEN OTHERS THEN
                                WS_HTML_D := TRIM(WS_VALOR);
							    WS_HTML_V := TRIM(WS_VALOR);
							END;
							
							HTP.P('<li data-chave="'||WS_CHAVE||'" '||WS_OBRIGATORIO||' style="order: '||WS_DADO.ORDEM||'; '||WS_INVISIVEL||'" data-tipo="'||WS_DADO.TIPO_INPUT||'" data-d="'||REPLACE(WS_HTML_D, CHR(34), '$[DQUOTE]')||'" data-v="'||REPLACE(WS_HTML_V, CHR(34), '$[DQUOTE]')||'" data-c="'||WS_DADO.CD_COLUNA||'">');

					    ELSE
                            IF WS_DADO.TIPO_INPUT = 'sequence' AND NVL(PRM_CHAVE, 'N/A') = 'N/A' THEN 
                                WS_HTML_D := TRIM(WS_VALOR);
								WS_HTML_V := '0';
                            ELSE
                                WS_HTML_D := TRIM(WS_VALOR);
								WS_HTML_V := TRIM(WS_VALOR);
                            END IF;
							
							IF WS_DADO.TIPO_INPUT = 'sequence' OR WS_CHAVE = 1 THEN 
								HTP.P('<li class="readonly" data-chave="'||WS_CHAVE||'" '||WS_OBRIGATORIO||' style="order: '||WS_DADO.ORDEM||'; '||WS_INVISIVEL||'" data-tipo="'||WS_DADO.TIPO_INPUT||'" data-d="'||REPLACE(WS_HTML_D, CHR(34), '$[DQUOTE]')||'" data-v="'||REPLACE(WS_HTML_V, CHR(34), '$[DQUOTE]')||'" data-c="'||WS_DADO.CD_COLUNA||'">');
							ELSE
							    HTP.P('<li data-chave="'||WS_CHAVE||'" '||WS_OBRIGATORIO||' style="order: '||WS_DADO.ORDEM||'; '||WS_INVISIVEL||'" data-tipo="'||WS_DADO.TIPO_INPUT||'" data-d="'||REPLACE(WS_HTML_D, CHR(34), '$[DQUOTE]')||'" data-v="'||REPLACE(WS_HTML_V, CHR(34), '$[DQUOTE]')||'" data-c="'||WS_DADO.CD_COLUNA||'">');
                            END IF;

                        END IF;

                    ELSE
                        IF WS_DADO.TIPO_INPUT = 'data' THEN
	                        BEGIN
							    WS_HTML_D := TRIM(SUBSTR(WS_VALOR, 1, LENGTH(WS_VALOR)-5));
							    WS_HTML_V := TRIM(SUBSTR(WS_VALOR, 1, LENGTH(WS_VALOR)-5));
							EXCEPTION WHEN OTHERS THEN
                                WS_HTML_D := TRIM(WS_VALOR);
							    WS_HTML_V := TRIM(WS_VALOR);
							END;
							
							HTP.P('<li data-tipo="'||WS_DADO.TIPO_INPUT||'" data-chave="'||WS_CHAVE||'" '||WS_OBRIGATORIO||' style="order: '||WS_DADO.ORDEM||';'||WS_INVISIVEL||'" data-d="'||REPLACE(WS_HTML_D, CHR(34), '$[DQUOTE]')||'" data-v="'||REPLACE(WS_HTML_V, CHR(34), '$[DQUOTE]')||'" data-c="'||WS_DADO.CD_COLUNA||'">');

                        ELSE
                            IF WS_DADO.TIPO_INPUT = 'sequence' THEN 
                                WS_HTML_D := TRIM(WS_VALOR);
								WS_HTML_V := '0';
                            ELSE
                                WS_HTML_D := TRIM(WS_VALOR);
								WS_HTML_V := TRIM(WS_VALOR);
                            END IF;
							
							IF WS_DADO.TIPO_INPUT = 'textarea' THEN
						        WS_INVISIVEL := WS_INVISIVEL||' flex-basis: 100%;';
						    END IF;
							

                            IF WS_DADO.TIPO_INPUT = 'sequence' THEN 
							    HTP.P('<li class="invisible" data-tipo="'||WS_DADO.TIPO_INPUT||'" data-chave="'||WS_CHAVE||'"  style="order: '||WS_DADO.ORDEM||';'||WS_INVISIVEL||'" data-d="'||REPLACE(WS_HTML_D, CHR(34), '$[DQUOTE]')||'" data-v="'||REPLACE(WS_HTML_V, CHR(34), '$[DQUOTE]')||'" data-c="'||WS_DADO.CD_COLUNA||'">');
                            ELSE
                                HTP.P('<li data-tipo="'||WS_DADO.TIPO_INPUT||'" data-chave="'||WS_CHAVE||'" '||WS_OBRIGATORIO||' style="order: '||WS_DADO.ORDEM||';'||WS_INVISIVEL||'" data-d="'||REPLACE(WS_HTML_D, CHR(34), '$[DQUOTE]')||'" data-v="'||REPLACE(WS_HTML_V, CHR(34), '$[DQUOTE]')||'" data-c="'||WS_DADO.CD_COLUNA||'">');

							END IF;
							
                        END IF;

                    END IF;
					    
						HTP.P('<span>'||WS_DADO.NM_ROTULO||'</span>');

						IF (LENGTH(PRM_CHAVE) > 0 AND WS_CHAVE <> 0) OR WS_DADO.DS_ALINHAMENTO = 'xxx' THEN
						    
							    WS_HTML_V := FUN.CDESC(TRIM(WS_VALOR), WS_DADO.CD_LIGACAO);
								IF WS_DADO.TIPO_INPUT = 'data' THEN
								    WS_HTML_V := TRIM(SUBSTR(WS_HTML_V, 1, LENGTH(WS_HTML_V)-5));
								END IF;
						   
							    HTP.P('<input maxlength="'||WS_DADO.TAMANHO||'" data-evento="blur" style="text-align: '||WS_DADO.DS_ALINHAMENTO||';" type="text" placeholder="'||WS_DADO.NM_ROTULO||'" disabled value="'||WS_HTML_V||'"/>');
                        ELSE
						    CASE WS_DADO.TIPO_INPUT

							    WHEN 'textarea' THEN

									HTP.P('<textarea'||WS_READ||'id="browserdata-'||WS_COUNT||'" maxlength="'||WS_DADO.TAMANHO||'"  tabindex="'||WS_TAB||'" data-evento="blur|change" style="text-align: '||WS_DADO.DS_ALINHAMENTO||';" placeholder="'||WS_DADO.NM_ROTULO||'" >'||WS_VALOR||'</textarea>');

                                WHEN 'sequence' THEN

									HTP.P('<input disabled id="browserdata-'||WS_COUNT||'" tabindex="'||WS_TAB||'" style="text-align: '||WS_DADO.DS_ALINHAMENTO||';" type="text" placeholder="'||WS_DADO.NM_ROTULO||'" data-dados="'||WS_HTML_D||'" value="'||REPLACE(WS_HTML_V, '"', '')||'"/>');
								

								WHEN 'data' THEN

									HTP.P('<input'||WS_READ||'id="browserdata-'||WS_COUNT||'" maxlength="'||WS_DADO.TAMANHO||'" onkeydown="if(event.shiftKey === true && (event.keyCode == 190 || event.keyCode == 188)){ return false; event.preventDefault(); }" oninput=" this.value = VMasker.toPattern(this.value, ''99/99/9999'');"  tabindex="'||WS_TAB||'" data-evento="blur" style="text-align: '||WS_DADO.DS_ALINHAMENTO||';" type="text" placeholder="'||WS_DADO.NM_ROTULO||'" value="'||WS_HTML_V||'"/>');

                                WHEN 'datatime' THEN

									HTP.P('<input'||WS_READ||'id="browserdata-'||WS_COUNT||'" maxlength="'||WS_DADO.TAMANHO||'" onkeydown="if(event.shiftKey === true && (event.keyCode == 190 || event.keyCode == 188)){ return false; event.preventDefault(); }"  oninput=" this.value = VMasker.toPattern(this.value, ''99/99/9999 99:99'');" tabindex="'||WS_TAB||'" data-evento="blur" style="text-align: '||WS_DADO.DS_ALINHAMENTO||';" type="text" placeholder="'||WS_DADO.NM_ROTULO||'" value="'||WS_HTML_V||'"/>');

                                WHEN 'ligacao' THEN
                                    
									IF TRIM(WS_READ) = 'disabled' THEN
                                        HTP.P('<span id="browserdata-'||WS_COUNT||'" style="text-overflow: ellipsis; overflow: hidden; background: url(dwu.fcl.download?arquivo=seta.png) no-repeat scroll 98% 8px #FFF; max-width: none; width: 245px; flex: 1 0 calc(60% - 40px);" class="fakeoption readonly" title="" >'||FUN.CDESC(WS_VALOR, WS_DADO.CD_LIGACAO)||'</span>');
                                    ELSE
                                        HTP.P('<span id="browserdata-'||WS_COUNT||'" style="text-overflow: ellipsis; overflow: hidden; background: url(dwu.fcl.download?arquivo=seta.png) no-repeat scroll 98% 8px #FFF; max-width: none; width: 245px; flex: 1 0 calc(60% - 40px);" class="fakeoption" title="" onclick="fakeOption(''browserdata-'||WS_COUNT||''', ''Lista de valores'', ''valoresbrowser'', '''||WS_DADO.CD_LIGACAO||''');">'||FUN.CDESC(WS_VALOR, WS_DADO.CD_LIGACAO)||'</span>');
								    END IF;

								WHEN 'ligacaoc' THEN
                                    
									IF TRIM(WS_READ) = 'disabled' THEN
                                        HTP.P('<span id="browserdata-'||WS_COUNT||'" style="text-overflow: ellipsis; overflow: hidden; background: url(dwu.fcl.download?arquivo=seta.png) no-repeat scroll 98% 8px #FFF; max-width: none; width: 245px; flex: 1 0 calc(60% - 40px);" class="fakeoption readonly" title="" >'||WS_VALOR||' - '||FUN.CDESC(WS_VALOR, WS_DADO.CD_LIGACAO)||'</span>');
                                    ELSE
                                        HTP.P('<span id="browserdata-'||WS_COUNT||'" style="text-overflow: ellipsis; overflow: hidden; background: url(dwu.fcl.download?arquivo=seta.png) no-repeat scroll 98% 8px #FFF; max-width: none; width: 245px; flex: 1 0 calc(60% - 40px);" class="fakeoption" title="" onclick="fakeOption(''browserdata-'||WS_COUNT||''', ''Lista de valores'', ''valoresbrowser'', '''||WS_DADO.CD_LIGACAO||''');">'||WS_VALOR||' - '||FUN.CDESC(WS_VALOR, WS_DADO.CD_LIGACAO)||'</span>');
								    END IF;
									
								WHEN 'listboxp' THEN
								    
									HTP.P('<select'||WS_READ||'id="browserdata-'||WS_COUNT||'" data-evento="change" style="text-align: '||WS_DADO.DS_ALINHAMENTO||';">');
									    
                                        WS_COUNTER := 0;
                                        HTP.P('<option value="" hidden/>---</option>');
										FOR I IN(SELECT CD_COLUNA, CD_CONTEUDO FROM TABLE(FUN.VPIPE_PAR(REPLACE(WS_DADO.FORMULA, '$opc|', '')))) LOOP
                                            IF I.CD_COLUNA = NVL(WS_VALOR, WS_DADO.ST_DEFAULT) THEN
                                                HTP.P('<option value="'||I.CD_COLUNA||'" selected/>'||I.CD_CONTEUDO||'</option>');
                                            ELSE
                                                HTP.P('<option value="'||I.CD_COLUNA||'" />'||I.CD_CONTEUDO||'</option>');
                                            END IF;
                                        END LOOP;
									 HTP.P('</select>');
									 
                                WHEN 'listboxt' THEN
								    
									HTP.P('<select'||WS_READ||'id="browserdata-'||WS_COUNT||'" data-evento="change" style="text-align: '||WS_DADO.DS_ALINHAMENTO||';">');
									    
										WS_SQL := 'select distinct '||WS_DADO.CD_COLUNA||' from '||PRM_TABELA||' order by 1';

										WS_CURSOR := DBMS_SQL.OPEN_CURSOR;

										DBMS_SQL.PARSE(WS_CURSOR, WS_SQL, DBMS_SQL.NATIVE);
										DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, 1, WS_LISTA, 200);

										WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);

										LOOP
											WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_CURSOR);
											IF  WS_LINHAS <> 1 THEN 
											    EXIT; 
											END IF;
											DBMS_SQL.COLUMN_VALUE(WS_CURSOR, 1, WS_LISTA);

	                                        IF WS_VALOR = WS_LISTA THEN
											    HTP.P('<option value="'||WS_LISTA||'" selected>'||WS_LISTA||'</option>');
											ELSE
											    HTP.P('<option value="'||WS_LISTA||'">'||WS_LISTA||'</option>');
											END IF;
										 END LOOP;

										 DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
									HTP.P('</select>');
									
								ELSE
									BEGIN    
                                        IF LENGTH(WS_DADO.NM_MASCARA) > 0 THEN
										    
											IF WS_DADO.TIPO_INPUT = 'number' THEN
                                                WS_MASCARA := 'oninput="var precisao = '''||REPLACE(REPLACE(WS_DADO.NM_MASCARA, 'G', '.'), 'D', ',')||'''; if(precisao.split('','')[1]){ precisao = precisao.split('','')[1].length } else { precisao = 0; } VMasker(this).maskMoney({ precision: parseInt(precisao), separator: '','', delimiter: ''.'' });"';
	                                        ELSE
                                                WS_MASCARA := 'oninput=" this.value = VMasker.toPattern(this.value, '''||WS_DADO.NM_MASCARA||''')"';
                                            END IF;
											
                                            IF FUN.ISNUMBER(TRIM(WS_VALOR)) THEN
										        WS_HTML_D := TRIM(WS_VALOR);
												WS_HTML_V := TRIM(TO_CHAR(TRIM(WS_VALOR), WS_DADO.NM_MASCARA, 'NLS_NUMERIC_CHARACTERS = '||CHR(39)||FUN.RET_VAR('POINT')||CHR(39)));
											ELSE
												WS_HTML_D := TRIM(WS_VALOR);
												WS_HTML_V := TRIM(TO_CHAR(TRIM(WS_VALOR), WS_DADO.NM_MASCARA));
	                                        END IF;
											
	                                    ELSE
										    WS_MASCARA := '';
											WS_HTML_D := '';
											WS_HTML_V := TRIM(WS_VALOR);
										END IF;
                                    EXCEPTION WHEN OTHERS THEN
					                    WS_HTML_D := '';
										WS_HTML_V := TRIM(WS_VALOR);
									END;
									
									SELECT TAMANHO INTO WS_TAMANHO FROM DATA_COLUNA WHERE CD_MICRO_DATA = TRIM(PRM_OBJ) AND CD_COLUNA = WS_DADO.CD_COLUNA;

									IF(WS_DADO.TAMANHO > WS_TAMANHO) THEN
										WS_TAMANHO := WS_DADO.TAMANHO;
									ELSE
										WS_TAMANHO := WS_TAMANHO;

									END IF;
									
									HTP.P('<input onKeypress="return input(event, '''||WS_DADO.TIPO_INPUT||''')" '||WS_MASCARA||''||WS_READ||'maxlength="'||WS_TAMANHO||'" id="browserdata-'||WS_COUNT||'" tabindex="'||WS_TAB||'" data-evento="blur" style="text-align: '||WS_DADO.DS_ALINHAMENTO||';" type="text" placeholder="'||WS_DADO.NM_ROTULO||'" data-dados="'||WS_HTML_D||'" value="'||REPLACE(WS_HTML_V, '"', '')||'"/>');
									
							END CASE;
						END IF;

					EXCEPTION WHEN OTHERS THEN
                        HTP.P(SQLERRM);
					END;

					HTP.P('</li>');

				END LOOP;
			CLOSE CRS_DADOS;

		HTP.P('</ul>');

		EXCEPTION
		    WHEN WS_NOTFOUND THEN
				HTP.P('<div style="color: #CC0000;">'||SUBSTR(PRM_LINHAS(1), 11, LENGTH(PRM_LINHAS(1)))||FUN.LANG('ERRO DE ESTRUTURA')||'</div>');
				INSERT INTO LOG_EVENTOS VALUES (SYSDATE, PRM_LINHAS(1),WS_USUARIO,PRM_OBJ,'ERRORBROWSER','01');
			WHEN OTHERS THEN
	            INSERT INTO LOG_EVENTOS VALUES (SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' -- '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,WS_USUARIO,'','ERRORBROWSER','01');
	END BROWSEREDIT;

	PROCEDURE BROWSEREXCLUDE ( PRM_CHAVE VARCHAR2 DEFAULT NULL,
                               PRM_CAMPO VARCHAR2 DEFAULT NULL,
	                           PRM_VISAO VARCHAR2 DEFAULT NULL )  AS

		WS_SQL     VARCHAR2(4000);
        WS_COUNT   NUMBER;
        WS_COUNTC  NUMBER;
        WS_WHERE   VARCHAR2(2000);
        WS_LINHAS  NUMBER;
        WS_CURSOR  INTEGER;
        WS_TIPO    VARCHAR2(200);
        WS_TABELA  VARCHAR2(200);
        WS_COLUNA  VARCHAR2(200);
		WS_USUARIO VARCHAR2(80);

	BEGIN

	    WS_USUARIO := GBL.GETUSUARIO;

		BEGIN

            WS_COUNT := 0;
            FOR I IN(SELECT COLUMN_VALUE FROM TABLE(FUN.VPIPE(PRM_CAMPO))) LOOP
                WS_COUNT := WS_COUNT+1;
                WS_WHERE := WS_WHERE||' '||I.COLUMN_VALUE||' = '||':b'||TRIM(TO_CHAR(WS_COUNT, '900'))||' and ';
            END LOOP;

			SELECT ' DELETE FROM '||MICRO_DATA.NM_TABELA||' WHERE '||SUBSTR(WS_WHERE, 1, LENGTH(WS_WHERE)-4)
            INTO WS_SQL
			FROM MICRO_DATA
			WHERE MICRO_DATA.NM_MICRO_DATA = PRM_VISAO;
			
			SELECT NM_TABELA INTO WS_TABELA
			FROM MICRO_DATA
			WHERE MICRO_DATA.NM_MICRO_DATA = PRM_VISAO;

            WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
            DBMS_SQL.PARSE(WS_CURSOR, WS_SQL, DBMS_SQL.NATIVE);

            WS_COUNTC := 0;
            FOR A IN(SELECT COLUMN_VALUE FROM TABLE(FUN.VPIPE(PRM_CHAVE))) LOOP
                WS_COUNTC := WS_COUNTC+1;
                
                SELECT VALOR INTO WS_COLUNA FROM (SELECT COLUMN_VALUE AS VALOR, ROWNUM AS LINHA FROM TABLE(FUN.VPIPE(PRM_CAMPO))) WHERE LINHA = WS_COUNTC;
                
                SELECT TRIM(DATA_TYPE) INTO WS_TIPO FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = UPPER(TRIM(WS_TABELA)) AND COLUMN_NAME = WS_COLUNA;
                
                BEGIN
	                IF WS_TIPO = 'DATE' THEN
	                    DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_COUNTC, '900')), TO_DATE(TRIM(A.COLUMN_VALUE), 'DD/MM/YYYY HH24:MI', 'NLS_DATE_LANGUAGE=ENGLISH'));
	                ELSE
	                    DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_COUNTC, '900')), TRIM(A.COLUMN_VALUE));
	                END IF;
                EXCEPTION WHEN OTHERS THEN
	                BEGIN
	                    DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_COUNTC, '900')), TO_DATE(TRIM(A.COLUMN_VALUE), 'DD/MM/YYYY', 'NLS_DATE_LANGUAGE=ENGLISH'));
	                EXCEPTION WHEN OTHERS THEN
		                DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_COUNTC, '900')), TRIM(A.COLUMN_VALUE));
	                END;
	            END;

            END LOOP;
           
            WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);
            DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);

            HTP.P('OK');
            
            INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, 'Registro excluido chave #'||PRM_CHAVE||' com campo #'||PRM_CAMPO, WS_USUARIO, 'EVENTO');
            COMMIT;
		EXCEPTION WHEN OTHERS THEN
            HTP.P('ERROR: '||SQLERRM);
		    INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' -- '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BRO', WS_USUARIO, 'ERRO');
            COMMIT;
		END;
  
	END BROWSEREXCLUDE;
	

	PROCEDURE BROWSERMASK (  PRM_VALOR  VARCHAR2 DEFAULT NULL,
	                         PRM_COLUNA VARCHAR2 DEFAULT NULL,
							 PRM_VISAO  VARCHAR2 DEFAULT NULL,
							 PRM_TIPO   VARCHAR2 DEFAULT NULL ) AS

	    WS_CAMPO VARCHAR2(200);
	BEGIN

	    IF PRM_TIPO = 'check' THEN
			SELECT NVL(TAMANHO, 'N/A') INTO WS_CAMPO FROM DATA_COLUNA WHERE CD_MICRO_DATA = PRM_VISAO AND CD_COLUNA = PRM_COLUNA AND ROWNUM = 1;

			BEGIN
				IF WS_CAMPO <> 'N/A' THEN
					IF INSTR(WS_CAMPO, 'MAX') <> 0 THEN
						IF TO_NUMBER(REPLACE(WS_CAMPO, 'MAX', '')) > LENGTH(PRM_VALOR) THEN
							HTP.P('ok');
						ELSE
							HTP.P('error');
						END IF;
					ELSIF INSTR(WS_CAMPO, 'MIN')  <> 0 THEN
						IF TO_NUMBER(REPLACE(WS_CAMPO, 'MIN', '')) < LENGTH(PRM_VALOR) THEN
							HTP.P('ok');
						ELSE
							HTP.P('error');
						END IF;
					ELSE
						IF TO_NUMBER(WS_CAMPO) = LENGTH(PRM_VALOR) THEN
							HTP.P('ok');
						ELSE
							HTP.P('error');
						END IF;
					END IF;
				END IF;
			EXCEPTION WHEN OTHERS THEN
			    HTP.P('ok');
			END;
		ELSE
		    SELECT NM_MASCARA INTO WS_CAMPO FROM DATA_COLUNA WHERE CD_MICRO_DATA = PRM_VISAO AND CD_COLUNA = PRM_COLUNA AND ROWNUM = 1;

		    HTP.P(TO_CHAR(TO_NUMBER(TRIM(PRM_VALOR)), WS_CAMPO,'NLS_NUMERIC_CHARACTERS = '||FUN.RET_VAR('POINT')));
		END IF;

	END BROWSERMASK;

	PROCEDURE BROWSEREDITLINE ( PRM_TABELA        VARCHAR2 DEFAULT NULL,
								PRM_CHAVE         VARCHAR2 DEFAULT NULL,
								PRM_CAMPO         VARCHAR2 DEFAULT NULL,
								PRM_NOME          IN OWA_UTIL.VC_ARR,
								PRM_CONTEUDO      IN OWA_UTIL.VC_ARR,
								PRM_ANT           IN OWA_UTIL.VC_ARR,
                                PRM_TIPO          IN OWA_UTIL.VC_ARR,
                                PRM_OBJ           VARCHAR2 DEFAULT NULL ) AS


		WS_STATUS   VARCHAR2(4000);
	    WS_ERRO     EXCEPTION;
		WS_ADMIN    VARCHAR2(10);
		WS_USUARIO  VARCHAR2(80);

	BEGIN
	
	    WS_ADMIN   := GBL.GETNIVEL;
		WS_USUARIO := GBL.GETUSUARIO;

		BRO.PUT_LINHA(PRM_TABELA, PRM_CHAVE, PRM_CAMPO, PRM_NOME, PRM_CONTEUDO, PRM_ANT, PRM_TIPO, WS_STATUS, PRM_OBJ);

		IF WS_STATUS <> 'OK' THEN
		    IF WS_STATUS <> 'NOCHANGE' THEN
			    RAISE WS_ERRO;
			ELSE
			    HTP.P('#alert '||FUN.LANG('Sem altera&ccedil;&otilde;es')||'!');
			END IF;
		END IF;
		

	EXCEPTION
	    WHEN WS_ERRO THEN
		    IF WS_ADMIN = 'A' THEN
			    HTP.P('#alert '||WS_STATUS);
			ELSE
                INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' -- '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BRO', WS_USUARIO, 'ERRO');
                COMMIT;
			    HTP.P('#alert '||FUN.LANG('Ocorreu um erro, caso persista, contate o administrador')||'!');
			END IF;
		WHEN OTHERS THEN
	        IF WS_ADMIN = 'A' THEN
			    HTP.P('#alert Erro'||SQLERRM);
			ELSE
                INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' -- '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BRO', WS_USUARIO, 'ERRO');
                COMMIT;
			    HTP.P('#alert '||FUN.LANG('Ocorreu um erro, caso persista, contate o administrador')||'!');
			END IF;
	END BROWSEREDITLINE;
	

	PROCEDURE BROWSERNEWLINE (  PRM_TABELA        VARCHAR2 DEFAULT NULL,
								PRM_CHAVE         VARCHAR2 DEFAULT NULL,
								PRM_COLUNA        VARCHAR2 DEFAULT NULL,
								PRM_NOME          IN OWA_UTIL.VC_ARR,
								PRM_CONTEUDO      IN OWA_UTIL.VC_ARR,
                                PRM_TIPO          IN OWA_UTIL.VC_ARR,
                                PRM_IDENT         VARCHAR2 DEFAULT NULL,
                                PRM_SEQUENCE      VARCHAR2 DEFAULT 'false',
                                PRM_OBJ           VARCHAR2 DEFAULT NULL ) AS

		WS_STATUS  VARCHAR2(4000);
		WS_ERRO    EXCEPTION;
        WS_COUNT   NUMBER;
        WS_POINTER NUMBER;
        WS_SQL     VARCHAR2(4000);
        WS_SQL_R   NUMBER;
        WS_EXIST   EXCEPTION;
        WS_QUANT   VARCHAR2(10);
		WS_ADMIN   VARCHAR2(10);
		WS_USUARIO VARCHAR2(80);
	BEGIN

	    WS_ADMIN   := GBL.GETNIVEL;
		WS_USUARIO := GBL.GETUSUARIO;

        WS_SQL := 'select count(*) from '||PRM_TABELA||' where trim('||REPLACE(PRM_COLUNA, '|', ')||trim(')||') = '''||TRIM(REPLACE(PRM_IDENT, '|', ''))||'''';
		WS_POINTER := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(WS_POINTER, WS_SQL, DBMS_SQL.NATIVE);
        DBMS_SQL.DEFINE_COLUMN(WS_POINTER, 1, WS_QUANT, 10);
		WS_SQL_R := DBMS_SQL.EXECUTE_AND_FETCH(WS_POINTER);
        DBMS_SQL.COLUMN_VALUE(WS_POINTER, 1, WS_QUANT);
        DBMS_SQL.CLOSE_CURSOR(WS_POINTER);

        IF TO_NUMBER(WS_QUANT) > 0 AND PRM_SEQUENCE = 'false' THEN
            RAISE WS_EXIST;
        END IF;
 
		BRO.NEW_LINHA(PRM_TABELA, PRM_CHAVE, PRM_COLUNA, PRM_CONTEUDO, PRM_TIPO, WS_STATUS, PRM_OBJ);
       
		IF WS_STATUS <> 'OK' THEN
		    IF WS_STATUS <> 'NOCHANGE' THEN
			    RAISE WS_ERRO;
			ELSE
			    HTP.P('#alert '||FUN.LANG('Imposs&iacute;vel adicionar')||'!');
			END IF;
		ELSE
            INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, 'Linha adicionada no browser #'||PRM_TABELA, WS_USUARIO, 'EVENTO');
            COMMIT;
        END IF;

	EXCEPTION
        WHEN WS_EXIST THEN
            HTP.P('#alert Erro, id j&aacute; existente!');
	    WHEN WS_ERRO THEN
		    IF WS_ADMIN = 'A' THEN
			    HTP.P('#alert '||WS_STATUS);
			ELSE
			    IF INSTR(WS_STATUS, 'ORA-01400') <> 0 THEN
                    HTP.P('#alert '||FUN.LANG('N&atilde;o pode enviar campo vazio')||'!');
			    ELSE
			        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BRO', WS_USUARIO, 'ERRO');
                    COMMIT;
			        HTP.P('#alert '||FUN.LANG('Ocorreu um erro, caso persista, contate o administrador')||'!');
			    END IF;
			END IF;
		WHEN OTHERS THEN
	        IF WS_ADMIN = 'A' THEN
			    	HTP.P('#alert Erro '||WS_SQL);
			ELSE
                INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BRO', WS_USUARIO, 'ERRO');
                COMMIT;
			    HTP.P('#alert '||FUN.LANG('Ocorreu um erro, caso persista, contate o administrador')||'!');
			END IF;
	END BROWSERNEWLINE;

	PROCEDURE BROWSERCONFIG ( PRM_MICRODATA VARCHAR2 DEFAULT NULL) 
								
	AS
	    CURSOR CRS_COLUNAS IS
		SELECT CD_MICRO_DATA, CD_COLUNA, NM_ROTULO, NM_MASCARA, T3.NM_TABELA,
		CD_LIGACAO, ST_CHAVE, ST_BRANCO, ST_DEFAULT, ST_ALINHAMENTO, 
		ST_INVISIVEL, FORMULA, TIPO, DS_ALINHAMENTO, TIPO_INPUT, TAMANHO, 
		VALIDACAO, ORDEM, PERMISSAO, T2.DATA_TYPE
		FROM DATA_COLUNA T1
		LEFT JOIN MICRO_DATA T3 ON NM_MICRO_DATA = T1.CD_MICRO_DATA
		LEFT JOIN ALL_TAB_COLUMNS T2 ON T2.TABLE_NAME = T3.NM_TABELA AND T2.COLUMN_NAME = T1.CD_COLUNA
		WHERE CD_MICRO_DATA = PRM_MICRODATA
		ORDER BY CD_MICRO_DATA, ST_CHAVE DESC, ORDEM;

		WS_COLUNA CRS_COLUNAS%ROWTYPE;

		WS_PARAM  VARCHAR2(4000);
		WS_COUNT  NUMBER;
		WS_DECODE VARCHAR2(400);
		WS_CAPLENGTH NUMBER := 0;

	BEGIN

		HTP.P('<div id="boxbrowser">');
			HTP.P('<table id="browserconfig" class="linha">');
				HTP.P('<thead>');
					HTP.P('<tr>');
						
						HTP.P('<th title="'||FUN.LANG('COLUNA')||'">'||FUN.LANG('COLUNA')||'</th>');
						HTP.P('<th title="'||FUN.LANG('R&Oacute;TULO')||'">'||FUN.LANG('R&Oacute;TULO')||'</th>');
						HTP.P('<th title="'||FUN.LANG('ORDEM')||'">'||FUN.LANG('ORDEM')||'</th>');
						HTP.P('<th title="'||FUN.LANG('MASCARA')||'">'||FUN.LANG('MASCARA')||'</th>');
						HTP.P('<th title="'||FUN.LANG('LIGA&Ccedil;&Atilde;O')||'">'||FUN.LANG('LIGA&Ccedil;&Atilde;O')||'</th>');
						HTP.P('<th title="'||FUN.LANG('CHAVE')||'">'||FUN.LANG('CHAVE')||'</th>');
						HTP.P('<th title="'||FUN.LANG('OBRIGAT&Oacute;RIO')||'">'||FUN.LANG('OBRIGAT&Oacute;RIO')||'</th>');
						HTP.P('<th title="DEFAULT">DEFAULT</th>');
						HTP.P('<th title="'||FUN.LANG('ALINHAMENTO')||'">'||FUN.LANG('ALINHAMENTO')||'</th>');
						HTP.P('<th title="'||FUN.LANG('VISIBILIDADE')||'">'||FUN.LANG('VISIBILIDADE')||'</th>');
						HTP.P('<th title="'||FUN.LANG('FORMULA')||'">'||FUN.LANG('FORMULA')||'</th>');
						HTP.P('<th title="'||FUN.LANG('TIPO')||'">'||FUN.LANG('TIPO')||'</th>');
						HTP.P('<th title="'||FUN.LANG('ALINHAMENTO MENU')||'">'||FUN.LANG('ALINHAMENTO MENU')||'</th>');
						HTP.P('<th title="INPUT">INPUT</th>');
						HTP.P('<th title="'||FUN.LANG('TAMANHO')||'">'||FUN.LANG('TAMANHO')||'</th>');
						HTP.P('<th title="'||FUN.LANG('VALIDA&Ccedil;&Atilde;O')||'">'||FUN.LANG('VALIDA&Ccedil;&Atilde;O')||'</th>');
						
						HTP.P('<th title="'||FUN.LANG('PERMISS&Atilde;O')||'">'||FUN.LANG('PERMISS&Atilde;O')||'</th>');
						HTP.P('<th title="'||FUN.LANG('A&Ccedil;&Otilde;ES')||'"></th>');
					HTP.P('</tr>');
				HTP.P('</thead>');
				
				WS_COUNT := 0;
				
				HTP.P('<tbody>');
					OPEN CRS_COLUNAS;
						LOOP
							FETCH CRS_COLUNAS INTO WS_COLUNA;
							EXIT WHEN CRS_COLUNAS%NOTFOUND;

							WS_COUNT := WS_COUNT+1;

							HTP.P('<tr>');
								
								HTP.P('<td><input type="text" readonly value="'||WS_COLUNA.CD_COLUNA||'" /></li>');
								HTP.P('<td><input id="rotulo-'||WS_COUNT||'" type="text" value="'||WS_COLUNA.NM_ROTULO||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');
								HTP.P('<td><input id="ordem-'||WS_COUNT||'" type="number" value="'||WS_COLUNA.ORDEM||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');
								HTP.P('<td><input id="mascara-'||WS_COUNT||'" title="EX: 99/99/9999, 999G999D99, 999.999,99 &#10; $[COD] para o c�digo da liga&ccedil;&atilde;o e $[DESC] para descri&ccedil;&atilde;o da liga&ccedil;&atilde;o" type="text" value="'||WS_COLUNA.NM_MASCARA||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');

								

								HTP.P('<td>');
									HTP.P('<a class="script" onclick="this.parentNode.parentNode.lastElementChild.children[0].click();"></a>');
									FCL.FAKEOPTION('ligacao-'||WS_COUNT, ''||WS_COLUNA.CD_LIGACAO||'', ''||WS_COLUNA.CD_LIGACAO||'', 'lista-taux-fixa', 'N', 'N');
									
									
									
								HTP.P('</td>');
								
								
								

								HTP.P('<td>');
									HTP.P('<select id="chave-'||WS_COUNT||'" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();">');
										IF WS_COLUNA.ST_CHAVE = '0' THEN
											HTP.P('<option value="0" selected>'||FUN.LANG('N&atilde;o')||'</option>');
											HTP.P('<option value="1">'||FUN.LANG('Sim')||'</option>');
										ELSE
											HTP.P('<option value="0">'||FUN.LANG('N&atilde;o')||'</option>');
											HTP.P('<option value="1" selected>'||FUN.LANG('Sim')||'</option>');
										END IF;
									HTP.P('</select>');
								HTP.P('</td>');

								
								
								HTP.P('<td>');
									HTP.P('<select id="branco-'||WS_COUNT||'" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();">');
										IF NVL(WS_COLUNA.ST_BRANCO, '0') = '0' THEN
											HTP.P('<option value="0" selected>'||FUN.LANG('N&atilde;o')||'</option>');
											HTP.P('<option value="1">'||FUN.LANG('Sim')||'</option>');
										ELSE
											HTP.P('<option value="0">'||FUN.LANG('N&atilde;o')||'</option>');
											HTP.P('<option value="1" selected>'||FUN.LANG('Sim')||'</option>');
										END IF;
									HTP.P('</select>');
								HTP.P('</td>');
								
								HTP.P('<td><input id="default-'||WS_COUNT||'" type="text" value="'||WS_COLUNA.ST_DEFAULT||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');
								HTP.P('<td>');
									HTP.P('<select id="alinhamento-'||WS_COUNT||'" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();">');
										HTP.P('<option value="center">'||FUN.LANG('Centro')||'</option>');
										IF WS_COLUNA.ST_ALINHAMENTO = 'left' THEN
											HTP.P('<option value="left" selected>'||FUN.LANG('Esquerda')||'</option>');
										ELSE
											HTP.P('<option value="left">'||FUN.LANG('Esquerda')||'</option>');
										END IF;
										IF WS_COLUNA.ST_ALINHAMENTO = 'right' THEN
											HTP.P('<option value="right" selected>'||FUN.LANG('Direita')||'</option>');
										ELSE
											HTP.P('<option value="right">'||FUN.LANG('Direita')||'</option>');
										END IF;
									HTP.P('</select>');
								HTP.P('</td>');
								HTP.P('<td>');
									HTP.P('<select id="invisivel-'||WS_COUNT||'" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();">');
										IF WS_COLUNA.ST_INVISIVEL = 'N' THEN
											HTP.P('<option value="B">'||FUN.LANG('Browser')||'</option>');
											HTP.P('<option value="E">'||FUN.LANG('Edi&ccedil;&atilde;o')||'</option>');
											HTP.P('<option value="N" selected>'||FUN.LANG('Browser e Edi&ccedil;&atilde;o')||'</option>');
											HTP.P('<option value="S">'||FUN.LANG('Nenhum')||'</option>');
										ELSIF WS_COLUNA.ST_INVISIVEL = 'B' THEN
											HTP.P('<option value="B" selected>'||FUN.LANG('Browser')||'</option>');
											HTP.P('<option value="E">'||FUN.LANG('Edi&ccedil;&atilde;o')||'</option>');
											HTP.P('<option value="N">'||FUN.LANG('Browser e Edi&ccedil;&atilde;o')||'</option>');
											HTP.P('<option value="S">'||FUN.LANG('Nenhum')||'</option>');
										ELSIF WS_COLUNA.ST_INVISIVEL = 'E' THEN
											HTP.P('<option value="B">'||FUN.LANG('Browser')||'</option>');
											HTP.P('<option value="E" selected>'||FUN.LANG('Edi&ccedil;&atilde;o')||'</option>');
											HTP.P('<option value="N">'||FUN.LANG('Browser e Edi&ccedil;&atilde;o')||'</option>');
											HTP.P('<option value="S">'||FUN.LANG('Nenhum')||'</option>');
										ELSE
											HTP.P('<option value="B">'||FUN.LANG('Browser')||'</option>');
											HTP.P('<option value="E">'||FUN.LANG('Edi&ccedil;&atilde;o')||'</option>');
											HTP.P('<option value="N">'||FUN.LANG('Browser e Edi&ccedil;&atilde;o')||'</option>');
											HTP.P('<option value="S" selected>'||FUN.LANG('Nenhum')||'</option>');
										END IF;
									HTP.P('</select>');
								HTP.P('</td>');
								HTP.P('<td><textarea id="formula-'||WS_COUNT||'" value="'||WS_COLUNA.FORMULA||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();">'||WS_COLUNA.FORMULA||'</textarea></li>');
								
								HTP.P('<td><input id="tipo-'||WS_COUNT||'" type="text" value="'||WS_COLUNA.TIPO||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');
								HTP.P('<td>');
									HTP.P('<select id="alignds-'||WS_COUNT||'" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();">');
										HTP.P('<option value="center">'||FUN.LANG('Centro')||'</option>');
										IF WS_COLUNA.DS_ALINHAMENTO = 'left' THEN
											HTP.P('<option value="left" selected>'||FUN.LANG('Esquerda')||'</option>');
										ELSE
											HTP.P('<option value="left">'||FUN.LANG('Esquerda')||'</option>');
										END IF;
										IF WS_COLUNA.DS_ALINHAMENTO = 'right' THEN
											HTP.P('<option value="right" selected>'||FUN.LANG('Direita')||'</option>');
										ELSE
											HTP.P('<option value="right">'||FUN.LANG('Direita')||'</option>');
										END IF;
									HTP.P('</select>');
								HTP.P('</td>');
								
								
								
								SELECT DECODE(WS_COLUNA.TIPO_INPUT, 'text', 'TEXTO', 'textarea', 'TEXTO GRANDE', 'DATE', 'DATA', 'number', 'N&Uacute;MERO', 'ligacao', 'LIGA&Ccedil;&Atilde;O', 'listboxp', 'LISTA PR&Eacute;-DEFINIDA', 'listboxt', 'LISTA DA TABELA', 'sequence', 'SEQUENCIA', 'link', 'LINK', WS_COLUNA.TIPO_INPUT) INTO WS_DECODE FROM DUAL;
								
								
								
								
								
								HTP.P('<td>');
									HTP.P('<a class="script" onclick="this.parentNode.parentNode.lastElementChild.children[0].click();"></a>');
									FCL.FAKEOPTION('tipoinput-'||WS_COUNT, WS_DECODE, WS_COLUNA.TIPO_INPUT, 'lista-input-browser', 'N', 'N', '', '', WS_COLUNA.DATA_TYPE, WS_DECODE);
								HTP.P('</td>');
								
								

































































								BEGIN
									SELECT DATA_LENGTH INTO WS_CAPLENGTH FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = WS_COLUNA.NM_TABELA AND COLUMN_NAME = TRIM(WS_COLUNA.CD_COLUNA);
								EXCEPTION WHEN OTHERS THEN
									HTP.P(SQLERRM);
								END;

								HTP.P('<td><input id="tamanho-'||WS_COUNT||'" type="number" max="'||WS_CAPLENGTH||'" value="'||WS_COLUNA.TAMANHO||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');
								HTP.P('<td><input id="validacao-'||WS_COUNT||'" type="text" value="'||WS_COLUNA.VALIDACAO||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');
								
								HTP.P('<td>');
									








									
									
									
									
									HTP.P('<a class="script" onclick="call(''browser_permissao'', ''prm_micro_data='||PRM_MICRODATA||'&prm_coluna='||WS_COLUNA.CD_COLUNA||'&prm_valor=''+this.nextElementSibling.title, ''BRO'').then(function(resposta){ alerta(''feed-fixo'', TR_AL); });"></a>');
									FCL.FAKEOPTION('permissao-'||WS_COUNT, '', WS_COLUNA.PERMISSAO, 'lista-permissao-browser', 'N', 'S', PRM_MICRODATA, 'EDITAR CAMPO', WS_COLUNA.CD_COLUNA);
								
								
								HTP.P('</td>');

								WS_PARAM := 'prm_microdata='||WS_COLUNA.CD_MICRO_DATA||'&prm_coluna='||WS_COLUNA.CD_COLUNA||'&prm_rotulo=''+encodeURIComponent(document.getElementById(''rotulo-'||WS_COUNT||''').value)+''&prm_mascara=''+document.getElementById(''mascara-'||WS_COUNT||''').value+''&prm_ligacao=''+document.getElementById(''ligacao-'||WS_COUNT||''').title+''&prm_chave=''+document.getElementById(''chave-'||WS_COUNT||''').value+''&prm_branco=''+document.getElementById(''branco-'||WS_COUNT||''').value+''&prm_default=''+document.getElementById(''default-'||WS_COUNT||''').value+''&prm_alinhamento=''+document.getElementById(''alinhamento-'||WS_COUNT||''').value+''&prm_invisivel=''+document.getElementById(''invisivel-'||WS_COUNT||''').value+''&prm_formula=''+document.getElementById(''formula-'||WS_COUNT||''').value+''&prm_tipo=''+document.getElementById(''tipo-'||WS_COUNT||''').value+''&prm_alignds=''+document.getElementById(''alignds-'||WS_COUNT||''').value+''&prm_tipoinput=''+document.getElementById(''tipoinput-'||WS_COUNT||''').title+''&prm_tamanho=''+document.getElementById(''tamanho-'||WS_COUNT||''').value+''&prm_validacao=''+document.getElementById(''validacao-'||WS_COUNT||''').value+''&prm_ordem=''+document.getElementById(''ordem-'||WS_COUNT||''').value+''&prm_permissao=';

								HTP.P('<td>');
									HTP.P('<a class="link inv" onclick="var linha = this.parentNode.parentNode; ajax(''return'', ''browserConfig_alter'', '''||WS_PARAM||'&prm_acao=update'', true, '''', '''', '''', ''bro''); if(respostaAjax != ''FAIL''){ call(''menu'', ''prm_objeto='||PRM_MICRODATA||''', ''bro'').then(function(resposta){ document.getElementById(''bro-menu'').innerHTML = resposta; }); alerta(''msg'', TR_AL); } else { alerta(''msg'', TR_ER); }">GRAVAR</a>');
									
									HTP.P('<a class="remove" title="'||FUN.LANG('Excluir linha')||'" onclick="if(confirm(TR_OB_EX)){ ajax(''return'', ''browserConfig_alter'', '''||WS_PARAM||'&prm_acao=delete'', false, '''', '''', '''', ''bro''); if(respostaAjax != ''FAIL''){ noerror(this, TR_EX, ''msg''); setTimeout(function(){ carregaPainel(''browser&prm_default='||PRM_MICRODATA||'|''+document.getElementById('''||PRM_MICRODATA||'_fake'').getAtttribute(''data-visao'')); }, 200); } else { alerta(''msg'', TR_EX); }}">X</a>');
								HTP.P('</td>');
							HTP.P('</tr>');
						END LOOP;
					CLOSE CRS_COLUNAS;
				HTP.P('</tbody>');
			HTP.P('</div>');
		HTP.P('</div>');

	END BROWSERCONFIG;

	PROCEDURE BROWSERCONFIG_ALTER ( PRM_MICRODATA   VARCHAR2 DEFAULT NULL,
	                                PRM_COLUNA      VARCHAR2 DEFAULT NULL,
	                                PRM_ROTULO      VARCHAR2 DEFAULT NULL,
	                                PRM_MASCARA     VARCHAR2 DEFAULT NULL,
									PRM_LIGACAO     VARCHAR2 DEFAULT 'SEM',
	                                PRM_CHAVE       NUMBER DEFAULT 0,
	                                PRM_BRANCO      VARCHAR2 DEFAULT NULL,
									PRM_DEFAULT     VARCHAR2 DEFAULT NULL,
									PRM_ALINHAMENTO VARCHAR2 DEFAULT 'left',
									PRM_INVISIVEL   VARCHAR2 DEFAULT 'N',
									PRM_FORMULA     VARCHAR2 DEFAULT NULL,
									PRM_TIPO        VARCHAR2 DEFAULT 'N',
									PRM_ALIGNDS     VARCHAR2 DEFAULT 'left',
									PRM_TIPOINPUT   VARCHAR2 DEFAULT 'text',
									PRM_TAMANHO     VARCHAR2 DEFAULT NULL,
									PRM_VALIDACAO   VARCHAR2 DEFAULT NULL,
									PRM_ORDEM       NUMBER   DEFAULT 99,
									PRM_PERMISSAO   VARCHAR2 DEFAULT 'R',
									PRM_ACAO        VARCHAR2 DEFAULT 'update' ) AS

		WS_CHAVE     NUMBER  := 0;
		WS_COUNT     NUMBER;
		WS_FAIL      EXCEPTION;
		WS_MASCARA   VARCHAR2(200) := '';
		WS_TABELA    VARCHAR2(200);
		WS_TIPO      VARCHAR2(200);
		WS_TIPOINPUT VARCHAR2(200);

	BEGIN

	    CASE PRM_ACAO
		    WHEN 'update' THEN
			    BEGIN

	                



					IF PRM_INVISIVEL = 'S' OR PRM_INVISIVEL = 'E' THEN  
						UPDATE OBJECT_ATTRIB SET 
							PROPRIEDADE = '1'
						WHERE CD_OBJECT = PRM_MICRODATA AND 
						CD_PROP = 'DIRECTION';
						COMMIT;	
					END IF;
					
					UPDATE DATA_COLUNA SET
					NM_ROTULO = FUN.CONVERTE(PRM_ROTULO),
					NM_MASCARA = PRM_MASCARA,
					CD_LIGACAO = PRM_LIGACAO,
					ST_BRANCO = PRM_BRANCO,
					ST_DEFAULT = PRM_DEFAULT,
					ST_ALINHAMENTO = PRM_ALINHAMENTO,
					ST_INVISIVEL = PRM_INVISIVEL,
	                ST_CHAVE = PRM_CHAVE,
					FORMULA = PRM_FORMULA,
					TIPO = PRM_TIPO,
					DS_ALINHAMENTO = PRM_ALIGNDS,
					TIPO_INPUT = PRM_TIPOINPUT,
					TAMANHO = PRM_TAMANHO,
					VALIDACAO = PRM_VALIDACAO,
					ORDEM = PRM_ORDEM

					WHERE CD_COLUNA = PRM_COLUNA AND
					CD_MICRO_DATA = PRM_MICRODATA;
	                HTP.P('OK');
				EXCEPTION WHEN OTHERS THEN
				    RAISE WS_FAIL;
	
				END;

			WHEN 'insert' THEN
				BEGIN

	

	                IF NVL(PRM_COLUNA, 'N/A') = 'N/A' THEN 
						RAISE WS_FAIL;
					END IF;
					
					SELECT NM_TABELA INTO WS_TABELA FROM MICRO_DATA WHERE NM_MICRO_DATA = UPPER(PRM_MICRODATA);
	
	                SELECT DATA_TYPE INTO WS_TIPO FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = WS_TABELA AND COLUMN_NAME = UPPER(PRM_COLUNA);
	
	                IF INSTR(UPPER(PRM_COLUNA), 'CD_') > 0 THEN
					    WS_CHAVE := 1;
					END IF;
					
					IF WS_TIPO = 'DATE' THEN
					    WS_TIPOINPUT := 'data';
					END IF;
					
					IF INSTR(UPPER(PRM_COLUNA), 'DT_') > 0 AND WS_TIPO <> 'DATE' THEN
					    WS_MASCARA := '99/99/9999';
					END IF;
					
					IF INSTR(UPPER(PRM_COLUNA), 'DS_') > 0 THEN
					    WS_TIPOINPUT := 'textarea';
					END IF;
					
					IF WS_TIPO = 'NUMBER' THEN
					    WS_TIPOINPUT := 'number';
					END IF;
	 
	
					INSERT INTO DATA_COLUNA
					(CD_MICRO_DATA, CD_COLUNA, NM_ROTULO, NM_MASCARA, CD_LIGACAO, ST_CHAVE, ST_BRANCO, ST_DEFAULT, ST_ALINHAMENTO, ST_INVISIVEL, FORMULA, TIPO, DS_ALINHAMENTO, TIPO_INPUT, TAMANHO, VALIDACAO, ORDEM, PERMISSAO)
					VALUES
					(UPPER(PRM_MICRODATA), UPPER(PRM_COLUNA), PRM_ROTULO, WS_MASCARA, PRM_LIGACAO, WS_CHAVE, PRM_BRANCO, PRM_DEFAULT, PRM_ALINHAMENTO, PRM_INVISIVEL, PRM_FORMULA, PRM_TIPO, PRM_ALIGNDS, WS_TIPOINPUT, PRM_TAMANHO, PRM_VALIDACAO, PRM_ORDEM, PRM_PERMISSAO);
	                
                    
                    COMMIT;
                    HTP.P('OK');
	            EXCEPTION WHEN OTHERS THEN
				    RAISE WS_FAIL;
				END;
			WHEN 'delete' THEN
				BEGIN
				    DELETE FROM DATA_COLUNA
					WHERE CD_COLUNA = PRM_COLUNA AND
					CD_MICRO_DATA = PRM_MICRODATA;
	                HTP.P('OK');
				EXCEPTION WHEN OTHERS THEN
				    RAISE WS_FAIL;
				END;
			ELSE
			    HTP.P('');
		END CASE;
	EXCEPTION
	    WHEN WS_FAIL THEN
            ROLLBACK;
		    HTP.P('FAIL '||DBMS_UTILITY.FORMAT_ERROR_STACK||' -- '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	    WHEN OTHERS THEN
		    HTP.P('FAIL');
	END BROWSERCONFIG_ALTER;
	
	PROCEDURE BROWSER_PERMISSAO ( PRM_MICRO_DATA VARCHAR2 DEFAULT NULL,
	                              PRM_COLUNA     VARCHAR2 DEFAULT NULL,
	                              PRM_VALOR      VARCHAR2 DEFAULT NULL ) AS
	
	BEGIN
	
	    UPDATE DATA_COLUNA
	    SET PERMISSAO = PRM_VALOR
	    WHERE CD_MICRO_DATA = PRM_MICRO_DATA AND
	    CD_COLUNA = PRM_COLUNA;
	    COMMIT;
	    
	    HTP.P('OK');
	EXCEPTION WHEN OTHERS THEN
	    HTP.P('Erro ao alterar a permiss&atilde;o');
	END BROWSER_PERMISSAO;

	PROCEDURE DT_PAGINATION ( PRM_MICRO_DATA VARCHAR2 DEFAULT NULL,
	                          PRM_COLUNA     VARCHAR2 DEFAULT NULL,
	                          PRM_OBJID      VARCHAR2 DEFAULT NULL,
							  PRM_CHAVE      VARCHAR2 DEFAULT NULL,
                              PRM_ORDEM      VARCHAR2 DEFAULT NULL,
	                          PRM_SCREEN     VARCHAR2 DEFAULT NULL,
	                          PRM_LIMITE     NUMBER   DEFAULT 10,
							  PRM_ORIGEM     NUMBER   DEFAULT 0,
							  PRM_DIRECAO    VARCHAR2 DEFAULT '>',
	                          PRM_BUSCA      VARCHAR2 DEFAULT NULL,
							  PRM_CONDICAO   VARCHAR2 DEFAULT NULL,
							  PRM_ACUMULADO  VARCHAR2 DEFAULT NULL ) AS
							  
							  


		
		CURSOR NC_COLUNAS IS 
		SELECT CD_COLUNA, NM_ROTULO, NM_MASCARA, ST_CHAVE, ST_DEFAULT, CD_LIGACAO, FORMULA, ST_ALINHAMENTO, DS_ALINHAMENTO, TIPO_INPUT, COLUMN_ID, TAMANHO, DATA_LENGTH, ORDEM, PERMISSAO, ST_INVISIVEL, VIRTUAL_COLUMN
		FROM DATA_COLUNA, ALL_TAB_COLS
		WHERE CD_MICRO_DATA = TRIM(PRM_OBJID)
		AND COLUMN_NAME = CD_COLUNA AND
		TRIM(TABLE_NAME) = TRIM(PRM_MICRO_DATA)
		ORDER BY COLUMN_ID, ST_CHAVE, ORDEM, PERMISSAO;
		
		TYPE NCTYPE IS TABLE OF NC_COLUNAS%ROWTYPE;

		WS_LINHA            VARCHAR2(200);
		WS_FIRSTID			CHAR(1);
		WS_COUNTER			NUMBER := 1;
		WS_CURSOR			INTEGER;
		WS_QUERY_MONTADA	DBMS_SQL.VARCHAR2A;
		WS_LQUERY			NUMBER;
		WS_NCOLUMNS			DBMS_SQL.VARCHAR2_TABLE;
		WS_COLUNA_ANT		DBMS_SQL.VARCHAR2_TABLE;
		WS_SQL				LONG;
		RET_COLUNA			VARCHAR2(2000);
		RET_COLUNA_OUT      VARCHAR2(2000);
		RET_MCOL			NCTYPE; 
		WS_LINHAS			INTEGER;
		WS_CCOLUNA			NUMBER := 1;
		WS_VAZIO			BOOLEAN := TRUE;
		WS_NODATA       	EXCEPTION;
		WS_SEMQUERY			EXCEPTION;
		WS_QUERYOC			LONG;
		WS_SQL_PIVOT		LONG;
		WS_PARSEERR			EXCEPTION;
		WS_QUERY_PIVOT		LONG;
		WS_LIMITE_FINAL     NUMBER;
		WS_STYLE            VARCHAR2(600) := '';
		WS_CLASS            VARCHAR2(80) := '';
		WS_HINT             VARCHAR2(4000) := '';
        WS_CHAVE            VARCHAR2(600);
        WS_BLINK_LINHA      VARCHAR2(2000) := 'N/A';
        WS_ID               VARCHAR2(4000);
		WS_ID_LINHA         VARCHAR2(4000);
        WS_COUNT_BLINK      NUMBER;
        WS_COLUNAB           VARCHAR2(400);
        WS_CONTADOR         NUMBER := 0;
	    WS_COUNT_FILES      NUMBER;
	    WS_ID_DOC           VARCHAR2(32000);
	    WS_COUNT_CHAVE      NUMBER;
		WS_VALOR            VARCHAR2(2000);
		WS_ADMIN            VARCHAR2(10);
		WS_USUARIO          VARCHAR2(80);
		WS_DATAD            VARCHAR2(4000);
	BEGIN

	    WS_ADMIN   := NVL(GBL.GETNIVEL, 'N');
		WS_USUARIO := GBL.GETUSUARIO;

	    OPEN NC_COLUNAS;
		LOOP
		    FETCH NC_COLUNAS BULK COLLECT INTO RET_MCOL LIMIT 200;
		    EXIT WHEN NC_COLUNAS%NOTFOUND;
		END LOOP;
		CLOSE NC_COLUNAS;

		BEGIN   
            WS_SQL := CORE.DATA_DIRECT(PRM_MICRO_DATA, PRM_COLUNA, WS_QUERY_MONTADA, WS_LQUERY, WS_NCOLUMNS, REPLACE(PRM_OBJID, ' full', ''), PRM_CHAVE, PRM_ORDEM, PRM_SCREEN, PRM_LIMITE, PRM_ORIGEM, PRM_DIRECAO, WS_LIMITE_FINAL, PRM_CONDICAO, FUN.CONVERTE(PRM_BUSCA), PRM_ACUMULADO => PRM_ACUMULADO);
        END;

		WS_QUERYOC := '';
		WS_COUNTER := 0;

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

		BEGIN
			WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
			DBMS_SQL.PARSE( C => WS_CURSOR, STATEMENT => WS_QUERY_MONTADA, LB => 1, UB => WS_LQUERY, LFFLG => TRUE, LANGUAGE_FLAG => DBMS_SQL.NATIVE );
			WS_COUNTER := 0;
			LOOP
			    WS_COUNTER := WS_COUNTER + 1;
			    IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
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
	      		RAISE WS_PARSEERR;
	        END IF;
			DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
		EXCEPTION
		    WHEN OTHERS THEN
		    	RAISE WS_PARSEERR;
		END;

		WS_FIRSTID := 'Y';

		WS_CURSOR := DBMS_SQL.OPEN_CURSOR;

		DBMS_SQL.PARSE( C => WS_CURSOR, STATEMENT => WS_QUERY_MONTADA, LB => 1, UB => WS_LQUERY, LFFLG => TRUE, LANGUAGE_FLAG => DBMS_SQL.NATIVE );

		WS_COUNTER := 0;
		LOOP
		    WS_COUNTER := WS_COUNTER + 1;
		    IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
		    	EXIT;
		    END IF;
		    DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, RET_COLUNA, 2000);
		END LOOP;

		WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);
        
		
		WS_ID_DOC := '';
		WS_LINHA := 0;
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
		    WS_COUNTER := 0;

			DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_NCOLUMNS.COUNT, WS_LINHA);
			DBMS_SQL.COLUMN_VALUE(WS_CURSOR, 1, RET_COLUNA);

			WS_ID_LINHA := TRIM(RET_COLUNA);
           
			HTP.P('<tr id="B'||REPLACE(REPLACE(REPLACE(TRIM(RET_COLUNA), ' ', ''), '/', ''), ':', '')||'-'||WS_LINHA||'" class="'||WS_LINHA||'">');

			
            WS_ID_DOC  := '';
			WS_ID      := '';
			WS_COUNTER := 0;
			
			LOOP
				WS_COUNTER := WS_COUNTER + 1;
				IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
					EXIT;
				END IF;

				IF WS_NCOLUMNS(WS_COUNTER) <> 'DWU_ROWID' AND WS_NCOLUMNS(WS_COUNTER) <> 'DWU_ROWNUM' THEN

					WS_COUNT_CHAVE := 1;
					
					LOOP
						IF RET_MCOL(WS_COUNT_CHAVE).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
							EXIT;
						END IF;
						WS_COUNT_CHAVE := WS_COUNT_CHAVE + 1;
					END LOOP;

					DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_COUNTER, WS_ID_DOC);

					IF RET_MCOL(WS_COUNT_CHAVE).ST_CHAVE = '1' THEN
						WS_ID := WS_ID||'|'||WS_ID_DOC;
					END IF;
					
				END IF;
			END LOOP;

	        IF FUN.GETPROP(PRM_OBJID,'UPLOAD') = 'S' THEN
	            SELECT COUNT(*) INTO WS_COUNT_FILES FROM TAB_DOCUMENTOS WHERE USUARIO = PRM_OBJID||WS_ID;
	            HTP.P('<td class="attach" title="'||WS_COUNT_FILES||' '||FUN.LANG('arquivos anexos a linha')||'">');
	                HTP.P('<div class="attach-div">');
	                    HTP.P('<svg class="attach-svg N'||WS_COUNT_FILES||'" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 351.136 351.136" style="enable-background:new 0 0 351.136 351.136;" xml:space="preserve"> <g> <g id="Clips_2_"> <g> <path d="M324.572,42.699c-35.419-35.419-92.855-35.419-128.273,0L19.931,219.066c-26.575,26.575-26.575,69.635,0,96.211 c21.904,21.904,54.942,25.441,80.769,11.224c2.698-0.136,5.351-1.156,7.415-3.197l176.367-176.367 c17.709-17.709,17.709-46.416,0-64.125s-46.416-17.709-64.125,0L76.052,227.116c-4.422,4.422-4.422,11.61,0,16.031 c4.422,4.422,11.61,4.422,16.031,0L236.388,98.843c8.866-8.866,23.219-8.866,32.063,0c8.866,8.866,8.866,23.219,0,32.063 L100.088,299.268c-17.709,17.709-46.416,17.709-64.125,0s-17.709-46.416,0-64.125L212.33,58.73 c26.575-26.575,69.635-26.575,96.211,0c26.575,26.575,26.575,69.635,0,96.211L148.205,315.277c-4.422,4.422-4.422,11.61,0,16.031 c4.422,4.422,11.61,4.422,16.031,0l160.336-160.336C359.991,135.554,359.991,78.118,324.572,42.699z"/> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');	
	                HTP.P('</span>');
	            HTP.P('</td>');
	        END IF;

			WS_COUNT_BLINK := 0;

            
		    SELECT COUNT(*) INTO WS_COUNT_BLINK FROM DESTAQUE WHERE TRIM(CD_OBJETO) = TRIM(REPLACE(PRM_OBJID, ' full', '')) AND TRIM(TIPO_DESTAQUE) = 'estrela' AND (CD_USUARIO = WS_USUARIO OR CD_USUARIO = 'DWU');
			
			IF WS_COUNT_BLINK > 0 THEN
		        HTP.P('<td class="destaqueicon">');
		            HTP.P('<svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 19.481 19.481" xmlns:xlink="http://www.w3.org/1999/xlink" enable-background="new 0 0 19.481 19.481"> <g> <path d="m10.201,.758l2.478,5.865 6.344,.545c0.44,0.038 0.619,0.587 0.285,0.876l-4.812,4.169 1.442,6.202c0.1,0.431-0.367,0.77-0.745,0.541l-5.452-3.288-5.452,3.288c-0.379,0.228-0.845-0.111-0.745-0.541l1.442-6.202-4.813-4.17c-0.334-0.289-0.156-0.838 0.285-0.876l6.344-.545 2.478-5.864c0.172-0.408 0.749-0.408 0.921,0z"/> </g> </svg>');
		        HTP.P('</td>');
            END IF;
			
			WS_COUNTER := 0;

		    LOOP
				WS_COUNTER := WS_COUNTER + 1;
				IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
					EXIT;
				END IF;

	            IF WS_NCOLUMNS(WS_COUNTER) <> 'DWU_ROWID' AND WS_NCOLUMNS(WS_COUNTER) <> 'DWU_ROWNUM' THEN
					WS_CCOLUNA := 1;
					LOOP
						IF RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
							EXIT;
						END IF;
						WS_CCOLUNA := WS_CCOLUNA + 1;
					END LOOP;

					DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_COUNTER, RET_COLUNA);

					IF WS_COUNTER = 1 THEN
	                    WS_CHAVE := RET_COLUNA;
	                END IF;

					IF (RET_MCOL(WS_CCOLUNA).ST_INVISIVEL = 'S' OR RET_MCOL(WS_CCOLUNA).ST_INVISIVEL = 'E') OR (RET_MCOL(WS_CCOLUNA).VIRTUAL_COLUMN = 'YES') THEN
						WS_CLASS := ' inv';
					ELSE
						WS_CLASS := '';
					END IF;

					IF LENGTH(WS_STYLE) > 0 THEN
						WS_STYLE := ' style="'||WS_STYLE||'"';
					END IF;

					WS_DATAD := '';
                    
					IF RET_MCOL(WS_CCOLUNA).ST_CHAVE = '1' THEN
	                    WS_CHAVE := 'class="chave'||WS_CLASS||'"';
						IF NVL(TRIM(RET_COLUNA), 'N/A') <> 'N/A' THEN
							WS_DATAD := 'data-d="'||TRIM(RET_COLUNA)||'"';
						END IF;
	                ELSE
	                    WS_CHAVE := 'class="'||TRIM(WS_CLASS)||'"';
	                END IF;

					WS_HINT := '';

					BEGIN
					 
					    RET_COLUNA_OUT := RET_COLUNA;
					 
						IF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'data' THEN
							RET_COLUNA_OUT := TRIM(SUBSTR(RET_COLUNA_OUT, 1, LENGTH(RET_COLUNA_OUT)-5));
						END IF;
						
						IF LENGTH(TRIM(RET_COLUNA_OUT)) > 50 THEN
							WS_COLUNAB := TRIM(SUBSTR(RET_COLUNA_OUT, 1, 50))||'...';
						ELSE
							WS_COLUNAB := TRIM(RET_COLUNA_OUT);
						END IF;
						
					EXCEPTION WHEN OTHERS THEN
						WS_COLUNAB := TRIM(RET_COLUNA_OUT);
					END;
  
                    BEGIN
		                IF LENGTH(RET_MCOL(WS_CCOLUNA).NM_MASCARA) > 0 THEN
		                    IF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'data' AND NVL(RET_COLUNA, 'N/A') <> 'N/A' THEN 
                                BEGIN
								    HTP.P('<td '||WS_STYLE||''||NVL(WS_HINT, ' ')||''||WS_CHAVE||' '||WS_DATAD||'>'||TO_CHAR(TO_DATE(WS_COLUNAB, 'DD/MM/YYYY','NLS_DATE_LANGUAGE=ENGLISH'), 'DD/MM/YYYY', 'NLS_DATE_LANGUAGE=PORTUGUESE')||'</td>');
                                EXCEPTION WHEN OTHERS THEN
								    HTP.P('<td '||WS_STYLE||''||NVL(WS_HINT, ' ')||''||WS_CHAVE||' '||WS_DATAD||'>'||TO_CHAR(TO_DATE(WS_COLUNAB), 'DD/MM/YYYY')||'</td>');

								END;
							ELSIF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'datatime' AND NVL(RET_COLUNA, 'N/A') <> 'N/A' THEN 
                                
								HTP.P('<td '||WS_STYLE||''||NVL(WS_HINT, ' ')||''||WS_CHAVE||' '||WS_DATAD||'>'||WS_COLUNAB||'</td>');
								
							ELSIF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'link' THEN
                                HTP.P('<td class="'||WS_CLASS||'" '||WS_STYLE||''||NVL(WS_HINT, ' ')||''||WS_CHAVE||' '||WS_DATAD||' onclick="if(('''||TRIM(RET_COLUNA)||''').length > 0){ event.stopPropagation(); window.open(''http://'||REPLACE(RET_COLUNA, 'http://', '')||'''); }" class="link">'||TRIM(WS_COLUNAB)||'</td>');
                            ELSIF FUN.ISNUMBER(TRIM(RET_COLUNA)) AND RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'number' THEN
		                        HTP.P('<td '||WS_STYLE||''||NVL(WS_HINT, ' ')||''||WS_CHAVE||' '||WS_DATAD||'>'||TO_CHAR(WS_COLUNAB, RET_MCOL(WS_CCOLUNA).NM_MASCARA, 'NLS_NUMERIC_CHARACTERS = '||CHR(39)||FUN.RET_VAR('POINT')||CHR(39))||'</td>');
		                    ELSE
		                    
							    IF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'listboxp' THEN
							        SELECT CD_CONTEUDO INTO WS_VALOR FROM TABLE(FUN.VPIPE_PAR((RET_MCOL(WS_CCOLUNA).FORMULA))) WHERE TRIM(CD_COLUNA) = TRIM(RET_COLUNA);
							    ELSE
							        IF LENGTH(TRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA)) > 0 AND (INSTR(RET_MCOL(WS_CCOLUNA).NM_MASCARA, '$[DESC]') > 0 OR INSTR(RET_MCOL(WS_CCOLUNA).NM_MASCARA, '$[COD]') > 0) THEN
								        WS_VALOR := TRIM(REPLACE(REPLACE(RET_MCOL(WS_CCOLUNA).NM_MASCARA, '$[DESC]', FUN.CDESC(TRIM(RET_COLUNA), RET_MCOL(WS_CCOLUNA).CD_LIGACAO)), '$[COD]', TRIM(RET_COLUNA)));
									ELSE
									    WS_VALOR := FUN.CDESC(TRIM(RET_COLUNA), RET_MCOL(WS_CCOLUNA).CD_LIGACAO);
									END IF;
							    END IF;

                                HTP.P('<td  '||WS_STYLE||''||NVL(WS_HINT, ' ')||''||WS_CHAVE||' '||WS_DATAD||'>'||WS_VALOR||'</td>');

							END IF;
		                ELSE
                            IF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'data' AND NVL(RET_COLUNA, 'N/A') <> 'N/A' THEN 
                                HTP.P('<td '||WS_STYLE||''||NVL(WS_HINT, ' ')||''||WS_CHAVE||' '||WS_DATAD||'>'||TO_CHAR(TO_DATE(WS_COLUNAB), 'DD/MM/YYYY')||'</td>');
							ELSIF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'datatime' AND NVL(RET_COLUNA, 'N/A') <> 'N/A' THEN 
								    HTP.P('<td '||WS_STYLE||''||NVL(WS_HINT, ' ')||''||WS_CHAVE||' '||WS_DATAD||'>'||WS_COLUNAB||'</td>');
							ELSIF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'link' THEN
                                HTP.P('<td '||WS_STYLE||''||NVL(WS_HINT, ' ')||''||WS_CHAVE||' '||WS_DATAD||' onclick="if(('''||TRIM(RET_COLUNA)||''').length > 0){ event.stopPropagation(); window.open(''http://'||REPLACE(RET_COLUNA, 'http://', '')||'''); }" class="link">'||TRIM(WS_COLUNAB)||'</td>');
                            ELSE
							    IF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'listboxp' THEN
							        SELECT CD_CONTEUDO INTO WS_VALOR FROM TABLE(FUN.VPIPE_PAR((RET_MCOL(WS_CCOLUNA).FORMULA))) WHERE TRIM(CD_COLUNA) = TRIM(RET_COLUNA);
							    ELSE
								    WS_VALOR := FUN.CDESC(TRIM(RET_COLUNA), RET_MCOL(WS_CCOLUNA).CD_LIGACAO);
							    END IF;
							    HTP.P('<td '||WS_STYLE||''||NVL(WS_HINT, ' ')||''||WS_CHAVE||' '||WS_DATAD||'>'||WS_VALOR||'</td>');
							END IF;
                        END IF;
	                EXCEPTION WHEN OTHERS THEN
					    
	                    HTP.P('<td '||WS_STYLE||''||NVL(WS_HINT, ' ')||''||WS_CHAVE||' '||WS_DATAD||'>'||WS_COLUNAB||'</td>');
	                END;
					WS_COLUNA_ANT(WS_COUNTER) := RET_COLUNA;
				END IF;

                IF LENGTH(FUN.CHECK_BLINK_LINHA(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, 'B'||WS_ID_LINHA||'-'||WS_LINHA||'', RET_COLUNA)) > 7 THEN
			        WS_BLINK_LINHA := WS_BLINK_LINHA||FUN.CHECK_BLINK_LINHA(REPLACE(PRM_OBJID, ' full', ''), RET_MCOL(WS_CCOLUNA).CD_COLUNA, 'B'||REPLACE(REPLACE(REPLACE(WS_ID_LINHA, ' ', ''), '/', ''), ':', '')||'-'||WS_LINHA||'', RET_COLUNA);
			    END IF;

			END LOOP;
		    WS_FIRSTID := 'N';

            IF WS_BLINK_LINHA <> 'N/A' THEN 
                HTP.P(REPLACE(WS_BLINK_LINHA, 'N/A', '')); 
            END IF;
	        WS_BLINK_LINHA := 'N/A';
            
		    HTP.P('</tr>');
		END LOOP;

		DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
	EXCEPTION
	    WHEN WS_NODATA THEN
		    INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, 'Sem dados - BRO', WS_USUARIO, 'ERRO');
            COMMIT;
			FCL.NEGADO(PRM_MICRO_DATA||' - '||FUN.LANG('Sem Dados no relat&oacute;rio')||'.');
	    WHEN WS_SEMQUERY THEN
		    HTP.P(SQLERRM);
		WHEN WS_PARSEERR THEN
		    IF WS_ADMIN = 'A' THEN
				HTP.P(WS_QUERYOC);
			ELSE
				HTP.P('SEM DADOS');
			END IF;
			INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, WS_QUERYOC||' - SEM DADOS - BRO', WS_USUARIO, 'ERRO');
            COMMIT;
        WHEN OTHERS THEN
            IF WS_ADMIN = 'A' THEN
				HTP.P(WS_QUERYOC);
			ELSE
				HTP.P('SEM DADOS');
			END IF;
			INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, WS_QUERYOC||' - SEM DADOS - BRO', WS_USUARIO, 'ERRO');
            COMMIT;
END DT_PAGINATION;

PROCEDURE ANEXO ( PRM_CHAVE VARCHAR2 DEFAULT NULL ) AS

  WS_SIZE    VARCHAR2(200);

BEGIN
  
    FCL.UPLOAD(PRM_CHAVE);

    HTP.P('<ul id="browseredit" class="'||PRM_CHAVE||'">');
	    FOR I IN (SELECT NAME, DOC_SIZE, USUARIO FROM TAB_DOCUMENTOS WHERE USUARIO = NVL(PRM_CHAVE, 'DWU') ORDER BY NAME DESC) LOOP
			HTP.P('<li class="fileupload">'); 
				HTP.P('<span><a class="link" href="dwu.fcl.download_tab?prm_arquivo='||I.NAME||'&prm_alternativo='||PRM_CHAVE||'" target="_blank">'||I.NAME||'</a></span>');
				WS_SIZE := TO_CHAR(I.DOC_SIZE/1024, '9999')||'KB';
				HTP.P('<span>'||WS_SIZE||'</span>');
				HTP.P('<span style="text-align: right;"><a style="position: relative;" class="remove" title="'||FUN.LANG('remover imagem')||'" onclick="if(confirm(TR_CE)){ ajax(''fly'', ''remove_image'', ''prm_img='||I.NAME||'&prm_user='||I.USUARIO||''', false); noerror(this, '''||FUN.LANG('Arquivo removido com sucesso')||'!'', ''msg''); }">X</a></span>');
			HTP.P('</li>');
        END LOOP;
	HTP.P('</ul>');

END ANEXO;


PROCEDURE PUT_LINHA  ( PRM_TABELA           VARCHAR2 DEFAULT NULL,
                       PRM_CHAVE            VARCHAR2 DEFAULT NULL,
	                   PRM_CAMPO            VARCHAR2 DEFAULT NULL,
	                   PRM_NOME             OWA_UTIL.VC_ARR,
	                   PRM_CONTEUDO         OWA_UTIL.VC_ARR,
	                   PRM_CONTEUDO_ANT     OWA_UTIL.VC_ARR,
	                   PRM_TIPO             OWA_UTIL.VC_ARR,
	                   PRM_STATUS           OUT VARCHAR2,
	                   PRM_OBJ              VARCHAR2 DEFAULT NULL
                      ) AS

    TYPE GENERIC_CURSOR IS REF CURSOR;

    CRS_SAIDA GENERIC_CURSOR;
    CURSOR CRS_SEQ (P_COLUNAS VARCHAR2) IS
                        SELECT COLUMN_VALUE AS CD_COLUNA,
                               ROWNUM      AS SEQUENCIA FROM 
                        TABLE(FUN.VPIPE(P_COLUNAS));

    WS_SEQ  			      CRS_SEQ%ROWTYPE;


    WS_CURSOR           INTEGER;
    WS_BUSCA            VARCHAR2(4000);
    WS_COLUNAS          VARCHAR2(4000);
    WS_UPDATE           VARCHAR2(4000);
    WS_CT_COL           INTEGER;
    WS_COUNTER          INTEGER;
    WS_LINHAS           INTEGER;
    WS_VIRGULA          CHAR(1);

    WS_LQUERY           NUMBER;
    RET_COLUNA          VARCHAR2(4000);

  	WS_COL_NAMES        VARCHAR2(4000);
    WS_REF              VARCHAR2(4000);
    WS_NOTFOUND         EXCEPTION;
    WS_STATUS           EXCEPTION;
    WS_VALORER          EXCEPTION;
    WS_CONTEUDO         VARCHAR2(4000);
    WS_CONTEUDO_ANT     VARCHAR2(4000);
	WS_CONTEUDO_SUM     VARCHAR2(12000);
    WS_ID               VARCHAR2(400);
    WS_CCOUNT           NUMBER;
    WS_NOCHANGE         EXCEPTION;
    
    WS_WHERE            VARCHAR2(4000);
    WS_COUNT            NUMBER;
    WS_COUNT_DIF        NUMBER;
	WS_TIPO             VARCHAR2(2000);
	WS_USUARIO          VARCHAR2(80);

BEGIN

    WS_USUARIO := GBL.GETUSUARIO;

	WS_UPDATE := 'UPDATE '||PRM_TABELA||' SET';


	SELECT TRIM(LISTAGG(COLUMN_NAME,'|') WITHIN GROUP (ORDER BY COLUMN_ID)) INTO WS_COLUNAS
	FROM   ALL_TAB_COLUMNS
	WHERE  TABLE_NAME = PRM_TABELA AND COLUMN_NAME IN (SELECT CD_COLUNA FROM DATA_COLUNA WHERE CD_MICRO_DATA = PRM_OBJ AND ST_CHAVE = 0);

	SELECT COUNT(*)   INTO WS_CT_COL
	FROM   TABLE(FUN.VPIPE(WS_COLUNAS));
	WS_REF := 'XXXX';

	WS_VIRGULA := '';

	 
	WS_CCOUNT    := 0;
	WS_COUNT_DIF := 0;
	
	
	
	OPEN CRS_SEQ (WS_COLUNAS);
	LOOP
		FETCH CRS_SEQ INTO WS_SEQ;
			  EXIT WHEN CRS_SEQ%NOTFOUND;
		BEGIN
		   
			WS_CCOUNT := WS_CCOUNT+1;
			WS_CONTEUDO := PRM_CONTEUDO(WS_CCOUNT);
			WS_CONTEUDO_ANT := PRM_CONTEUDO_ANT(WS_CCOUNT);
			
			BEGIN
				WS_CONTEUDO_SUM := WS_CONTEUDO_SUM||'|'||PRM_CONTEUDO(WS_CCOUNT);
			END;

		EXCEPTION WHEN OTHERS THEN
			RAISE WS_VALORER;      
		END;
			
			BEGIN
				IF  NVL(WS_CONTEUDO, 'N/A') <> NVL(WS_CONTEUDO_ANT, 'N/A') THEN
				
				    SELECT TIPO_INPUT INTO WS_TIPO FROM DATA_COLUNA WHERE CD_MICRO_DATA = PRM_OBJ AND CD_COLUNA = WS_SEQ.CD_COLUNA;
					
					
					
					
					    WS_UPDATE := WS_UPDATE||WS_VIRGULA||' '||TRIM(WS_SEQ.CD_COLUNA)||' = :b'||TRIM(TO_CHAR(WS_CCOUNT,'900'));
					
					WS_VIRGULA := ',';
					WS_COUNT_DIF := WS_COUNT_DIF+1; 
				END IF;
			
			END;

		   IF PRM_NOME(WS_CCOUNT) = PRM_CHAVE THEN
			   WS_ID := TRIM(WS_CONTEUDO);
		   END IF;

	END LOOP;
	CLOSE CRS_SEQ;
	
	

	IF WS_COUNT_DIF = 0 THEN
		RAISE WS_NOCHANGE;
	END IF;

	WS_COUNT := WS_CCOUNT;
	
	FOR I IN(SELECT VALOR AS COLUMN_VALUE FROM TABLE(FUN.VPIPE_ORDER(PRM_CAMPO)) WHERE VALOR NOT IN (SELECT COLUMN_NAME FROM ALL_TAB_COLS WHERE TRIM(TABLE_NAME) = TRIM(PRM_TABELA) AND VIRTUAL_COLUMN = 'YES')) LOOP
		WS_COUNT := WS_COUNT+1;
		WS_WHERE := WS_WHERE||' '||TRIM(I.COLUMN_VALUE)||' = '||':b'||TRIM(TO_CHAR(WS_COUNT, '900'))||' and ';
	END LOOP;

	WS_UPDATE := WS_UPDATE||WS_COL_NAMES||' WHERE '||SUBSTR(WS_WHERE, 1, LENGTH(WS_WHERE)-4);

	WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(WS_CURSOR, WS_UPDATE,DBMS_SQL.NATIVE);
	
	WS_CCOUNT := 0;

	
   OPEN CRS_SEQ (WS_COLUNAS);
		LOOP
			FETCH CRS_SEQ INTO WS_SEQ;
			EXIT WHEN CRS_SEQ%NOTFOUND;
			WS_CCOUNT := WS_CCOUNT+1;
			IF NVL(PRM_CONTEUDO(WS_CCOUNT), 'N/A') <> NVL(PRM_CONTEUDO_ANT(WS_CCOUNT), 'N/A')  THEN
				
				IF PRM_TIPO(WS_CCOUNT) <> 'data' AND PRM_TIPO(WS_CCOUNT) <> 'datatime' THEN
					RET_COLUNA := PRM_CONTEUDO(WS_CCOUNT);
					DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_CCOUNT,'900')), FUN.CONVERTE(PRM_CONTEUDO(WS_CCOUNT)));
				ELSE
					RET_COLUNA := TO_DATE(PRM_CONTEUDO(WS_CCOUNT), 'DD/MM/YYYY HH24:MI');
					DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_CCOUNT,'900')), TO_DATE(PRM_CONTEUDO(WS_CCOUNT), 'DD/MM/YYYY HH24:MI'));
				END IF;

				IF PRM_TIPO(WS_CCOUNT) = 'number' THEN
					RET_COLUNA := REPLACE(RET_COLUNA, ',', '');
					RET_COLUNA := TO_NUMBER(TRIM(RET_COLUNA));
					DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_CCOUNT,'900')), TRIM(RET_COLUNA));
				END IF;
				
			END IF;
		END LOOP;
	CLOSE CRS_SEQ;


	FOR A IN(SELECT VALOR AS COLUMN_VALUE FROM TABLE(FUN.VPIPE_ORDER(PRM_CHAVE)) WHERE VALOR NOT IN (SELECT COLUMN_NAME FROM ALL_TAB_COLS WHERE TRIM(TABLE_NAME) = TRIM(PRM_TABELA) AND VIRTUAL_COLUMN = 'YES')) LOOP
		WS_CCOUNT := WS_CCOUNT+1;
		DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_CCOUNT, '900')), TRIM(A.COLUMN_VALUE));
	END LOOP;

	WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);
	DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
	PRM_STATUS := 'OK';

    HTP.P(PRM_STATUS);

	





EXCEPTION
    WHEN WS_NOCHANGE THEN
        PRM_STATUS := FUN.LANG('Sem altera&ccedil;&otilde;es');
        HTP.P(PRM_STATUS);
    WHEN WS_VALORER THEN
        PRM_STATUS := DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' linha#'||WS_CCOUNT;
    WHEN WS_STATUS THEN
        PRM_STATUS := DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' '||WS_UPDATE;
    WHEN OTHERS THEN
        PRM_STATUS := DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' '||WS_UPDATE;

END PUT_LINHA;

PROCEDURE GET_LINHA  ( PRM_TABELA    VARCHAR2 DEFAULT NULL,
                       PRM_CHAVE     VARCHAR2 DEFAULT NULL,
                       PRM_COLUNA    VARCHAR2 DEFAULT NULL,
                       PRM_CONTEUDO  OUT DBMS_SQL.VARCHAR2_TABLE,
                       PRM_OBJ       VARCHAR2 DEFAULT NULL ) AS

    TYPE GENERIC_CURSOR IS REF CURSOR;

    CRS_SAIDA GENERIC_CURSOR;

    WS_CURSOR           INTEGER;
    WS_BUSCA            VARCHAR2(4000);
    WS_COLUNAS          VARCHAR2(4000);
    WS_CT_COL           INTEGER;
    WS_COUNTER          INTEGER;
    WS_LINHAS           INTEGER;
    WS_VIRGULA          CHAR(1);

    WS_LQUERY           NUMBER;
    RET_COLUNA          VARCHAR2(4000);

  	WS_QUERY_MONTADA	VARCHAR2(4000);
    WS_NOTFOUND         EXCEPTION;
    WS_ERRO             EXCEPTION;
    WS_COUNT            NUMBER;
    WS_COUNTC           NUMBER;
    WS_WHERE            VARCHAR2(4000);
    WS_TIPO             VARCHAR2(4000);
	WS_TEST             DATE;
	TYPE ARRAY_TIPO IS VARRAY(40) OF VARCHAR2(120);
    WS_ARRAY ARRAY_TIPO := ARRAY_TIPO(); 
BEGIN

   

	
    SELECT TRIM(LISTAGG(COLUMN_NAME,'|') WITHIN GROUP (ORDER BY COLUMN_ID)) INTO WS_COLUNAS
    FROM   ALL_TAB_COLUMNS
    WHERE  TABLE_NAME = PRM_TABELA AND COLUMN_NAME IN (SELECT CD_COLUNA FROM DATA_COLUNA WHERE CD_MICRO_DATA = PRM_OBJ);

    SELECT COUNT(*)  INTO WS_CT_COL
    FROM   TABLE(FUN.VPIPE(WS_COLUNAS));
    
    
    
    WS_COUNT := 0;
    FOR I IN(SELECT VALOR AS COLUMN_VALUE FROM TABLE(FUN.VPIPE_ORDER(PRM_COLUNA))) LOOP
        WS_COUNT := WS_COUNT+1;
        
        SELECT DATA_TYPE INTO WS_TIPO FROM ALL_TAB_COLUMNS
        WHERE TABLE_NAME = PRM_TABELA AND COLUMN_NAME = I.COLUMN_VALUE;
        
		WS_ARRAY.EXTEND;
		WS_ARRAY(WS_COUNT) := WS_TIPO;

		
        BEGIN
            IF WS_TIPO  = 'DATE' THEN
                WS_WHERE := WS_WHERE||' to_date(trim(to_char('||I.COLUMN_VALUE||', ''DD/MM/YYYY HH24:MI'')), ''DD/MM/YYYY HH24:MI'') = '||':b'||TRIM(TO_CHAR(WS_COUNT, '900'))||' and ';
            ELSE
                WS_WHERE := WS_WHERE||' trim('||I.COLUMN_VALUE||') = '||':b'||TRIM(TO_CHAR(WS_COUNT, '900'))||' and ';
            END IF;
        EXCEPTION WHEN OTHERS THEN
            WS_WHERE := WS_WHERE||' trim('||I.COLUMN_VALUE||') = '||':b'||TRIM(TO_CHAR(WS_COUNT, '900'))||' and ';
        END;
		

    END LOOP;


	
	

		FOR A IN(SELECT COLUMN_NAME, DATA_TYPE 
			FROM   ALL_TAB_COLUMNS
			WHERE  TABLE_NAME = PRM_TABELA AND COLUMN_NAME IN (SELECT CD_COLUNA FROM DATA_COLUNA WHERE CD_MICRO_DATA = PRM_OBJ) ORDER BY COLUMN_ID) LOOP
			
			IF A.DATA_TYPE = 'DATE' THEN
			    BEGIN
			        WS_QUERY_MONTADA := WS_QUERY_MONTADA||'trim(to_char('||A.COLUMN_NAME||', ''DD/MM/YYYY HH24:MI'')) as '||A.COLUMN_NAME||', ';
				EXCEPTION WHEN OTHERS THEN
				    WS_QUERY_MONTADA := WS_QUERY_MONTADA||A.COLUMN_NAME||', ';
				END;
			ELSE
			    WS_QUERY_MONTADA := WS_QUERY_MONTADA||A.COLUMN_NAME||', ';
			END IF;
		
		
		END LOOP;
		
		WS_QUERY_MONTADA := 'select '||SUBSTR(WS_QUERY_MONTADA, 1, LENGTH(WS_QUERY_MONTADA)-2)||' FROM '||PRM_TABELA||' WHERE '||SUBSTR(WS_WHERE, 1, LENGTH(WS_WHERE)-4);
	
	
    IF  TRIM(WS_COLUNAS) IS NOT NULL THEN

    	WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(WS_CURSOR, WS_QUERY_MONTADA,DBMS_SQL.NATIVE);
        
        WS_COUNTER := 0;
        LOOP
            WS_COUNTER := WS_COUNTER + 1;
            IF  WS_COUNTER > WS_CT_COL THEN
                EXIT;
            END IF;
            DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, RET_COLUNA, 4000);
			
        END LOOP;

        WS_COUNTC := 0;
        BEGIN
            FOR A IN(SELECT VALOR AS VALOR FROM TABLE(FUN.VPIPE_ORDER(PRM_CHAVE))) LOOP
			
			   
			
                WS_COUNTC := WS_COUNTC+1;
                BEGIN

				    IF WS_ARRAY(WS_COUNTC) = 'DATE' THEN
                    
						BEGIN
							
							DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_COUNTC, '900')), TO_DATE(TRIM(A.VALOR), 'DD/MM/YYYY HH24:MI'));
							
						
						EXCEPTION WHEN OTHERS THEN
							DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_COUNTC, '900')), A.VALOR);

						END;
						
					ELSE
                        DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_COUNTC, '900')), A.VALOR);
					END IF;
                EXCEPTION WHEN OTHERS THEN
                    DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_COUNTC, '900')), TRIM(A.VALOR));
                END;
            END LOOP;

        END;

        WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);

        WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_CURSOR);
        IF  WS_LINHAS = 0 THEN
            RAISE WS_NOTFOUND;
        END IF;

        WS_COUNTER := 0;
        LOOP
            WS_COUNTER := WS_COUNTER + 1;
            IF  WS_COUNTER > WS_CT_COL THEN
                EXIT;
            END IF;

            DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_COUNTER, RET_COLUNA);
            PRM_CONTEUDO(WS_COUNTER) := RET_COLUNA;
			
        END LOOP;

        DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);

    END IF;

EXCEPTION
    WHEN WS_ERRO THEN
        PRM_CONTEUDO(1) := DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    WHEN WS_NOTFOUND THEN
         PRM_CONTEUDO(1) := '%ERR%-UPQ-N&atilde;o Encontrado: ['||WS_CT_COL||''||PRM_CHAVE||']'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||'  '||WS_QUERY_MONTADA;
    WHEN OTHERS THEN
         PRM_CONTEUDO(1) := '%ERR%-UPQ-['||WS_CT_COL||'-'||PRM_CHAVE||']'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||WS_QUERY_MONTADA;

END GET_LINHA;

PROCEDURE NEW_LINHA  (  PRM_TABELA   VARCHAR2 DEFAULT NULL,
                        PRM_CHAVE    VARCHAR2 DEFAULT NULL,
                        PRM_COLUNA   VARCHAR2 DEFAULT NULL,
                        PRM_CONTEUDO OWA_UTIL.VC_ARR,
                        PRM_TIPO     OWA_UTIL.VC_ARR,
                        PRM_STATUS   OUT VARCHAR2,
                        PRM_OBJ      VARCHAR2 DEFAULT NULL
                        ) AS

    TYPE GENERIC_CURSOR IS REF CURSOR;

    CRS_SAIDA GENERIC_CURSOR;

	CURSOR CRS_SEQ (P_COLUNAS VARCHAR2) IS
        SELECT COLUMN_VALUE AS CD_COLUNA,
        ROWNUM AS SEQUENCIA FROM 
        TABLE(FUN.VPIPE(P_COLUNAS)) 
        WHERE COLUMN_VALUE NOT IN (SELECT COLUMN_NAME FROM ALL_TAB_COLS WHERE TRIM(TABLE_NAME) = TRIM(PRM_TABELA) AND VIRTUAL_COLUMN = 'YES');

    WS_SEQ CRS_SEQ%ROWTYPE;


    WS_CURSOR           INTEGER;
    WS_BUSCA            VARCHAR2(4000);
    WS_COLUNAS          VARCHAR2(4000);
    WS_INSERT           VARCHAR2(4000);
    WS_CT_COL           INTEGER;
    WS_COUNTER          INTEGER;
    WS_LINHAS           INTEGER;
    WS_VIRGULA          CHAR(1);

    WS_LQUERY           NUMBER;
    RET_COLUNA          VARCHAR2(2000);

  	WS_COL_NAMES        VARCHAR2(4000);
    WS_NOTFOUND         EXCEPTION;

    WS_COUNT_CHAVE      NUMBER;
    WS_SEQUENCE         NUMBER;
    WS_CONTEUDO         VARCHAR2(2000);
    WS_COLUNA_VIRTUAL   VARCHAR2(2000);
	WS_USUARIO          VARCHAR2(80);
    
BEGIN

    WS_USUARIO := GBL.GETUSUARIO;

    WS_INSERT := 'insert into '||PRM_TABELA||' ( ';
	
	SELECT TRIM(LISTAGG(CD_COLUNA,'|') WITHIN GROUP (ORDER BY CD_COLUNA)) INTO WS_COLUNA_VIRTUAL FROM DATA_COLUNA WHERE CD_MICRO_DATA = PRM_OBJ AND 
    CD_COLUNA NOT IN (SELECT COLUMN_NAME FROM ALL_TAB_COLS WHERE TRIM(TABLE_NAME) = TRIM(PRM_TABELA) AND VIRTUAL_COLUMN = 'YES');

    SELECT TRIM(LISTAGG(COLUMN_NAME,'|') WITHIN GROUP (ORDER BY COLUMN_ID)), COUNT(COLUMN_NAME) INTO WS_COLUNAS, WS_CT_COL
    FROM   ALL_TAB_COLUMNS
    WHERE  TABLE_NAME = PRM_TABELA AND COLUMN_NAME IN (SELECT COLUMN_VALUE FROM TABLE((FUN.VPIPE(WS_COLUNA_VIRTUAL))));

    SELECT 'insert into '||PRM_TABELA||' ('||LISTAGG(COLUMN_NAME,',')
           WITHIN GROUP (ORDER BY COLUMN_ID)||') values ('
           INTO WS_INSERT
    FROM   ALL_TAB_COLUMNS
    WHERE  TABLE_NAME = PRM_TABELA AND COLUMN_NAME IN (SELECT COLUMN_VALUE FROM TABLE((FUN.VPIPE(WS_COLUNA_VIRTUAL))));

    OPEN CRS_SEQ (WS_COLUNAS);
    LOOP
        FETCH CRS_SEQ INTO WS_SEQ;
              EXIT WHEN CRS_SEQ%NOTFOUND;

             WS_INSERT := WS_INSERT||WS_VIRGULA||' :b'||TRIM(TO_CHAR(WS_SEQ.SEQUENCIA,'900'));
             WS_VIRGULA := ',';
 
    END LOOP;
    CLOSE CRS_SEQ;
    WS_INSERT := WS_INSERT||')';

    WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(WS_CURSOR, WS_INSERT,DBMS_SQL.NATIVE);

    OPEN CRS_SEQ (WS_COLUNAS);
    LOOP
        FETCH CRS_SEQ INTO WS_SEQ;
            EXIT WHEN CRS_SEQ%NOTFOUND;
            WS_CONTEUDO := PRM_CONTEUDO(WS_SEQ.SEQUENCIA);
            IF PRM_TIPO(WS_SEQ.SEQUENCIA) = 'data' THEN
                DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_SEQ.SEQUENCIA,'900')), TO_DATE(WS_CONTEUDO, 'DD/MM/YYYY', 'NLS_DATE_LANGUAGE=ENGLISH'));
            ELSIF PRM_TIPO(WS_SEQ.SEQUENCIA) = 'datatime' THEN
                DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_SEQ.SEQUENCIA,'900')), TO_DATE(WS_CONTEUDO, 'DD/MM/YYYY HH24:MI', 'NLS_DATE_LANGUAGE=ENGLISH'));
			ELSE
                IF PRM_TIPO(WS_SEQ.SEQUENCIA) = 'number' OR PRM_TIPO(WS_SEQ.SEQUENCIA) = 'sequence' THEN
                    WS_CONTEUDO := REPLACE(WS_CONTEUDO, ',', '');
                    WS_CONTEUDO := TO_NUMBER(TRIM(WS_CONTEUDO));
                END IF;
                
				IF PRM_TIPO(WS_SEQ.SEQUENCIA) = 'sequence' THEN
				    WS_CONTEUDO := FUN.GET_SEQUENCE(PRM_TABELA, WS_SEQ.CD_COLUNA);
					UPDATE BI_SEQUENCE
					SET SEQUENCIA = WS_CONTEUDO
					WHERE NM_TABELA = PRM_TABELA AND NM_COLUNA = WS_SEQ.CD_COLUNA;
					COMMIT;
				END IF;


                DBMS_SQL.BIND_VARIABLE(WS_CURSOR, ':b'||TRIM(TO_CHAR(WS_SEQ.SEQUENCIA,'900')), FUN.CONVERTE(WS_CONTEUDO));
            END IF;

    END LOOP;
    CLOSE CRS_SEQ;

    PRM_STATUS := 'OK';

    WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);

EXCEPTION
    WHEN OTHERS THEN
        PRM_STATUS := DBMS_UTILITY.FORMAT_ERROR_STACK;
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, PRM_STATUS||' - BRO', WS_USUARIO, 'ERRO');
        COMMIT;
END NEW_LINHA;

PROCEDURE GET_TOTAL ( PRM_MICRODATA VARCHAR2 DEFAULT NULL,
                      PRM_OBJID     VARCHAR2 DEFAULT NULL,
                      PRM_SCREEN    VARCHAR2 DEFAULT NULL,
                      PRM_CONDICAO  VARCHAR2 DEFAULT NULL,
                      PRM_COLUNA    VARCHAR2 DEFAULT NULL,
                      PRM_CHAVE     VARCHAR2 DEFAULT NULL,
                      PRM_ORDEM     VARCHAR2 DEFAULT '1',
                      PRM_BUSCA     VARCHAR2 DEFAULT NULL  ) AS

    WS_LQUERY			NUMBER;
    WS_LIMITE_FINAL     NUMBER;
    WS_TOTAL            NUMBER;
    WS_CALC             NUMBER;
    WS_LINHAS           INTEGER;
    WS_CURSOR           INTEGER;
    WS_SQL              VARCHAR2(4000);
    WS_QUERY_COUNT	    DBMS_SQL.VARCHAR2A;
    WS_NCOLUMNS			DBMS_SQL.VARCHAR2_TABLE;
	WS_USUARIO          VARCHAR2(80);
    
    
    BEGIN

	    WS_USUARIO := GBL.GETUSUARIO;

	    BEGIN
		    WS_SQL := CORE.DATA_DIRECT(PRM_MICRODATA, PRM_COLUNA, WS_QUERY_COUNT, WS_LQUERY, WS_NCOLUMNS, PRM_OBJID, PRM_CHAVE, PRM_ORDEM, PRM_SCREEN, NVL(FUN.GETPROP(PRM_OBJID, 'LINHAS', 'DEFAULT', WS_USUARIO), 50), 0, '>', WS_LIMITE_FINAL, PRM_CONDICAO, PRM_BUSCA, PRM_COUNT => TRUE);
	    END;

	    WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
	    DBMS_SQL.PARSE( C => WS_CURSOR, STATEMENT => WS_QUERY_COUNT, LB => 1, UB => WS_LQUERY, LFFLG => TRUE, LANGUAGE_FLAG => DBMS_SQL.NATIVE );
		DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, 1, WS_TOTAL);
	    WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);
		WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_CURSOR);
	    DBMS_SQL.COLUMN_VALUE(WS_CURSOR, 1, WS_TOTAL);
	    DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);

	    WS_CALC := CEIL(WS_TOTAL/NVL(FUN.GETPROP(PRM_OBJID, 'LINHAS', 'DEFAULT', WS_USUARIO), 50));
	    IF WS_CALC < 1 THEN WS_CALC := 1; END IF;

        HTP.P('<h4 id="browser-page" class="'||WS_CALC||'" data-total="'||WS_TOTAL||'" data-pagina="1" style="position: fixed; bottom: 5px; right: 5px; font-size: 16px; color: #555; font-family: ''montserrat''; background: #EFEFEF; letter-spacing: 1px;">1/'||WS_CALC||'</h4>');

EXCEPTION WHEN OTHERS THEN
    HTP.P(SQLERRM);
END GET_TOTAL;

PROCEDURE MENU ( PRM_OBJETO VARCHAR2 DEFAULT NULL ) AS

    WS_COUNT        NUMBER;
    WS_LIGACAO      VARCHAR2(200);
    WS_DATA_COLUNA  VARCHAR2(2000);
    WS_CHAVE        VARCHAR2(2000);

BEGIN

    HTP.P('<select id="data-coluna">');
		FOR I IN(SELECT CD_COLUNA, NM_ROTULO, TIPO_INPUT FROM DATA_COLUNA WHERE CD_MICRO_DATA = PRM_OBJETO ORDER BY ST_CHAVE DESC) LOOP
			IF WS_COUNT = 0 THEN
                WS_LIGACAO := I.TIPO_INPUT;
            END IF;
            WS_COUNT := WS_COUNT +1;
            HTP.P('<option value="'||I.CD_COLUNA||'" data-tipo="'||I.TIPO_INPUT||'">'||I.NM_ROTULO||'</option>');
			WS_DATA_COLUNA := WS_DATA_COLUNA||'|'||I.CD_COLUNA;
		END LOOP;
	HTP.P('</select>');
	
	HTP.P('<input type="hidden" id="browser-coluna" value="'||WS_DATA_COLUNA||'">');
    SELECT TRIM((LISTAGG(CD_COLUNA, '|') WITHIN GROUP (ORDER BY COLUMN_ID, ORDEM, ROWNUM))) INTO WS_CHAVE FROM DATA_COLUNA LEFT JOIN ALL_TAB_COLUMNS ON TABLE_NAME = 'data_coluna' WHERE CD_MICRO_DATA = PRM_OBJETO AND ST_CHAVE = 1; 
	HTP.P('<input type="hidden" id="browser-chave" value="'||WS_CHAVE||'">');

END MENU;

PROCEDURE MAIN_DATA ( PRM_OBJID        VARCHAR2 DEFAULT NULL,
			          PRM_COLUNA       VARCHAR2 DEFAULT NULL,
			          PRM_MICRODATA    VARCHAR2 DEFAULT NULL,
			          PRM_SCREEN       VARCHAR2 DEFAULT 'DEFAULT',
					  PRM_CONDICAO     VARCHAR2 DEFAULT 'semelhante' ) AS

	CURSOR CRS_MICRO_DATA IS
	SELECT UPPER(NM_TABELA) AS TABELA, DS_MICRO_VISAO AS DESCRICAO
	FROM MICRO_DATA WHERE NM_MICRO_DATA = PRM_OBJID;

	WS_MICRO_DATA CRS_MICRO_DATA%ROWTYPE;
	
	

	TYPE WS_TMCOLUNAS IS TABLE OF DATA_COLUNA%ROWTYPE
	INDEX BY PLS_INTEGER;

	TYPE GENERIC_CURSOR IS REF CURSOR;

	CRS_SAIDA GENERIC_CURSOR;

	CURSOR NC_COLUNAS IS 
	SELECT CD_COLUNA, NM_ROTULO, NM_MASCARA, ST_CHAVE, ST_DEFAULT, CD_LIGACAO, FORMULA, ST_ALINHAMENTO, DS_ALINHAMENTO, TIPO_INPUT, COLUMN_ID, TAMANHO, DATA_LENGTH, ORDEM, PERMISSAO, ST_INVISIVEL, VIRTUAL_COLUMN
    FROM DATA_COLUNA, ALL_TAB_COLS
	WHERE CD_MICRO_DATA = TRIM(PRM_OBJID)
    AND COLUMN_NAME = CD_COLUNA AND
    TRIM(TABLE_NAME) = TRIM(PRM_MICRODATA)
	ORDER BY COLUMN_ID, ST_CHAVE, ORDEM, PERMISSAO;
	
	TYPE NCTYPE IS TABLE OF NC_COLUNAS%ROWTYPE;


	RET_COLUNA			VARCHAR2(2000);
	RET_COLUNA_OUT      VARCHAR2(2000);
	RET_MCOL			NCTYPE;

	WS_NCOLUMNS			DBMS_SQL.VARCHAR2_TABLE;
	WS_COLUNA_ANT		DBMS_SQL.VARCHAR2_TABLE;
	WS_PVCOLUMNS		DBMS_SQL.VARCHAR2_TABLE;
	WS_MFILTRO			DBMS_SQL.VARCHAR2_TABLE;
	WS_VCOL				DBMS_SQL.VARCHAR2_TABLE;
	WS_VCON				DBMS_SQL.VARCHAR2_TABLE;


	WS_OBJID			VARCHAR2(40);
	WS_QUERYOC			CLOB;
	WS_PIPE				CHAR(1);

	RET_COLUP			LONG;
	WS_LQUERY			NUMBER;
	WS_COUNTER			NUMBER := 1;
	WS_CCOLUNA			NUMBER := 1;
	WS_XCOLUNA			NUMBER := 0;
	WS_BINDN			NUMBER := 0;
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
	WS_XATALHO			LONG;

	WS_ACESSO			EXCEPTION;
	WS_SEMQUERY			EXCEPTION;
	WS_SEMPERMISSAO		EXCEPTION;
	WS_PCURSOR			INTEGER;
	WS_CURSOR			INTEGER;
	WS_LINHAS			INTEGER;
	WS_QUERY_MONTADA	DBMS_SQL.VARCHAR2A;
	WS_QUERY_PIVOT		LONG;
	WS_SQL				LONG;
	WS_SQL_PIVOT		LONG;
	WS_MODE				VARCHAR2(30);
	WS_FIRSTID			CHAR(1);

	WS_VAZIO			BOOLEAN := TRUE;
	WS_NODATA       	EXCEPTION;
	WS_INVALIDO			EXCEPTION;
	WS_CLOSE_HTML		EXCEPTION;
	WS_MOUNT			EXCEPTION;
	WS_PARSEERR			EXCEPTION;

	WS_STEP             NUMBER;
	WS_STEPPER          NUMBER := 0;
	WS_LINHA            VARCHAR2(3000);
	WS_LIMITE_FINAL     NUMBER;
	WS_QUERY            VARCHAR2(2000);
	WS_ORDER            VARCHAR2(90);
	WS_TPT              VARCHAR2(400);
	WS_COUNT            NUMBER;
	WS_STYLE            VARCHAR2(600) := '';
	WS_CLASS            VARCHAR2(80) := '';
	WS_HINT             VARCHAR2(4000) := '';
    WS_NULL             VARCHAR2(1) := NULL;
    WS_CHAVE            VARCHAR2(400);
    WS_BLINK_LINHA      VARCHAR2(4000) := 'N/A';
    WS_ID               VARCHAR2(4000);
	WS_ID_LINHA         VARCHAR2(4000);
    WS_COUNT_BLINK      NUMBER;
    WS_CONTADOR         NUMBER := 0;
    WS_COLUNAB          VARCHAR2(400);
	WS_COLUNAD          DATE;
    WS_COUNT_FILES      NUMBER;
    WS_ID_DOC           VARCHAR2(16000);
    WS_COUNT_CHAVE      NUMBER;
	WS_VALOR            VARCHAR2(2000);
	WS_EXTRA            NUMBER;
    WS_USUARIO          VARCHAR2(80);
    WS_ADMIN            VARCHAR2(4);
BEGIN
	
	WS_USUARIO := GBL.GETUSUARIO;
	WS_ADMIN   := GBL.GETNIVEL;
	
	
	
	
	
	IF NOT FUN.CHECK_USER(WS_USUARIO) OR NOT FUN.CHECK_NETWALL(WS_USUARIO) OR FUN.CHECK_SYS <> 'OPEN' THEN
        INSERT INTO LOG_EVENTOS VALUES(SYSDATE, 'Página Inicial', WS_USUARIO, 'chk_user', 'no_user', '01');
        RAISE WS_ACESSO;
    END IF;

    
	
	INSERT INTO LOG_EVENTOS VALUES(SYSDATE, PRM_OBJID||'/'||PRM_MICRODATA||'/'||PRM_SCREEN||'/'||PRM_CONDICAO||'/'||PRM_COLUNA, WS_USUARIO, 'BROWSER', 'ACESSO', '01');

	WS_COLUNA := PRM_COLUNA;

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
	END LOOP;

	WS_SQL_PIVOT := WS_QUERY_PIVOT;

    WS_OBJID := PRM_OBJID;
    
    BRO.GET_TOTAL(PRM_MICRODATA, PRM_OBJID, PRM_SCREEN, PRM_CONDICAO, PRM_COLUNA);

    BEGIN
	    WS_SQL := CORE.DATA_DIRECT(PRM_MICRODATA, WS_COLUNA, WS_QUERY_MONTADA, WS_LQUERY, WS_NCOLUMNS, PRM_OBJID, '', NVL(FUN.GETPROP(PRM_OBJID, 'DIRECTION', 'DEFAULT', WS_USUARIO), 1), PRM_SCREEN, NVL(FUN.GETPROP(PRM_OBJID, 'LINHAS', 'DEFAULT', WS_USUARIO), 100), 0, '>', WS_LIMITE_FINAL, PRM_CONDICAO, PRM_COUNT => FALSE);
	EXCEPTION WHEN OTHERS THEN
        HTP.P(WS_QUERY_MONTADA(6));
    END;


	BEGIN
		BEGIN
			WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
			DBMS_SQL.PARSE( C => WS_CURSOR, STATEMENT => WS_QUERY_MONTADA, LB => 1, UB => WS_LQUERY, LFFLG => TRUE, LANGUAGE_FLAG => DBMS_SQL.NATIVE );
            
	    EXCEPTION WHEN OTHERS THEN
		     HTP.P(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	    END;
		WS_COUNTER := 0;
		LOOP
		    WS_COUNTER := WS_COUNTER + 1;
		    IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
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
      		RAISE WS_PARSEERR;
        END IF;
		DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
	EXCEPTION
	    WHEN OTHERS THEN
            INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BRO', WS_USUARIO, 'ERRO');
            COMMIT;
	END;

	HTP.P('<div class="header" id="'||WS_OBJID||'header" style="background-color: '||FUN.GETPROP(PRM_OBJID, 'FUNDO_VALOR')||'; font-size: '||FUN.GETPROP(PRM_OBJID, 'SIZE', 'DEFAULT', WS_USUARIO)||'px;"></div>');
	HTP.P('<div class="corpo" style=" font-size: '||FUN.GETPROP(PRM_OBJID, 'SIZE', 'DEFAULT', WS_USUARIO)||'px;" id="'||WS_OBJID||'dv2">');

	HTP.P('<div id="'||WS_OBJID||'m">');
	
	
	HTP.TABLEOPEN( CATTRIBUTES => ' id="'||WS_OBJID||'c" ');

	WS_COUNTER   := 0;
	WS_CCOLUNA   := 0;
    WS_STEP := 0;
	HTP.P('<tbody></tbody>');
	HTP.P('<thead onclick="browserOrder(event)">');
        
	BEGIN

	HTP.P('<tr>');
        

		IF FUN.GETPROP(PRM_OBJID,'UPLOAD') = 'S' THEN
			HTP.PRN('<th style="width: 14px;"></th>');
		END IF;

		SELECT COUNT(*) INTO WS_COUNT_BLINK FROM DESTAQUE WHERE TRIM(CD_OBJETO) = TRIM(PRM_OBJID) AND TRIM(TIPO_DESTAQUE) = 'estrela' AND (CD_USUARIO = WS_USUARIO OR CD_USUARIO = 'DWU');
		IF WS_COUNT_BLINK > 0 THEN
			HTP.PRN('<th style="width: 14px;"></th>');
		END IF;

		LOOP

			WS_COUNTER   := WS_COUNTER   + 1;

			IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
				EXIT;
			END IF;

			IF WS_NCOLUMNS(WS_COUNTER) <> 'DWU_ROWID' AND WS_NCOLUMNS(WS_COUNTER) <> 'DWU_ROWNUM' THEN
				WS_CCOLUNA := 1;

				LOOP
					BEGIN
					IF  WS_CCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
						EXIT;
					END IF;
					EXCEPTION WHEN OTHERS THEN
						EXIT;
					END;
					WS_CCOLUNA := WS_CCOLUNA + 1;
				END LOOP;

				IF (RET_MCOL(WS_CCOLUNA).ST_INVISIVEL = 'S' OR RET_MCOL(WS_CCOLUNA).ST_INVISIVEL = 'E') OR (RET_MCOL(WS_CCOLUNA).VIRTUAL_COLUMN = 'YES') THEN
					WS_STYLE := 'style="text-align: '||RET_MCOL(WS_CCOLUNA).ST_ALINHAMENTO||';"';
					WS_CLASS := 'inv';
				ELSE
					WS_STYLE := 'style="text-align: '||RET_MCOL(WS_CCOLUNA).ST_ALINHAMENTO||';"';
					WS_CLASS := '';
				END IF;
				
				IF INSTR(TRIM(UPPER(FUN.GETPROP(PRM_OBJID, 'DIRECTION', 'DEFAULT', WS_USUARIO))), UPPER(TRIM(RET_MCOL(WS_CCOLUNA).CD_COLUNA))) > 0 THEN
					IF INSTR(TRIM(UPPER(FUN.GETPROP(PRM_OBJID, 'DIRECTION', 'DEFAULT', WS_USUARIO))), 'DESC') > 0 THEN
						WS_CLASS := WS_CLASS||' selectedbheader desc';
					ELSE
						WS_CLASS := WS_CLASS||' selectedbheader';
					END IF;
				END IF;

				IF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'data' OR RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'datatime' THEN
					HTP.PRN('<th class="'||WS_CLASS||'" data-coluna="'||RET_MCOL(WS_CCOLUNA).CD_COLUNA||'" data-ordem="TO_DATE('||RET_MCOL(WS_CCOLUNA).CD_COLUNA||', ''DD/MM/YYYY HH24:MI'')" id="B'||WS_NCOLUMNS(WS_COUNTER)||'" '||WS_STYLE||'>');
				ELSE
					HTP.PRN('<th class="'||WS_CLASS||'" data-coluna="'||RET_MCOL(WS_CCOLUNA).CD_COLUNA||'" data-ordem="'||RET_MCOL(WS_CCOLUNA).CD_COLUNA||'" id="B'||WS_NCOLUMNS(WS_COUNTER)||'" '||WS_STYLE||'>');
				END IF;
				
					HTP.P(RET_MCOL(WS_CCOLUNA).NM_ROTULO);

				HTP.P('</th>');
				
			END IF;
		END LOOP;
		HTP.P('</tr>');

	

		WS_STYLE := '';

		WS_BINDN  := 0;
		LOOP
			WS_BINDN := WS_BINDN + 1;
			IF  WS_BINDN > WS_PVCOLUMNS.COUNT THEN
			EXIT;
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
			DBMS_SQL.DEFINE_COLUMN(WS_PCURSOR, WS_COUNTER, RET_COLUP, 2000);
			END LOOP;

			WS_CCOLUNA := 1;
			LOOP
			IF  WS_CCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_PVCOLUMNS(WS_BINDN) THEN
				EXIT;
			END IF;
			WS_CCOLUNA := WS_CCOLUNA + 1;
			END LOOP;

			WS_LINHAS := DBMS_SQL.EXECUTE(WS_PCURSOR);

			HTP.TABLEROWOPEN( CATTRIBUTES => '');

			WS_CONTENT_ANT := '%First%';
			WS_XCOUNT      := 0;
			LOOP
			WS_LINHAS := DBMS_SQL.FETCH_ROWS(WS_PCURSOR);

			DBMS_SQL.COLUMN_VALUE(WS_PCURSOR, WS_BINDN, RET_COLUNA);
			IF  WS_CONTENT_ANT = '%First%' THEN
				WS_CONTENT_ANT := RET_COLUNA;
			END IF;

			WS_CONTENT_ANT := RET_COLUNA;
			WS_XCOUNT      := WS_XCOUNT + 1;
			END LOOP;

			IF (RET_MCOL(WS_CCOLUNA).ST_INVISIVEL = 'S' OR RET_MCOL(WS_CCOLUNA).ST_INVISIVEL = 'B') OR (RET_MCOL(WS_CCOLUNA).VIRTUAL_COLUMN = 'YES') THEN
				WS_STYLE := 'style="display: none;"';
			ELSE
				WS_STYLE := 'style="padding: 0; text-align: '||RET_MCOL(WS_CCOLUNA).ST_ALINHAMENTO||';"';
			END IF;

			HTP.P('<td colspan="1" style="'||WS_STYLE||'"></td>');
			


			HTP.P('</tr>');

			DBMS_SQL.CLOSE_CURSOR(WS_PCURSOR);

		END LOOP;

		WS_STYLE := '';

		HTP.P('</thead>');

	EXCEPTION WHEN OTHERS THEN
	    IF WS_ADMIN = 'A' THEN
			HTP.P(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
		ELSE
			HTP.P('SEM DADOS');
		END IF;
	END;

	WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
    BEGIN
	DBMS_SQL.PARSE( C => WS_CURSOR, STATEMENT => WS_QUERY_MONTADA, LB => 1, UB => WS_LQUERY, LFFLG => TRUE, LANGUAGE_FLAG => DBMS_SQL.NATIVE );
    EXCEPTION WHEN OTHERS THEN
	    IF WS_ADMIN = 'A' THEN
			HTP.P(WS_QUERY_MONTADA(1));
			HTP.P(WS_QUERY_MONTADA(2));
			HTP.P(WS_QUERY_MONTADA(3));
			HTP.P(WS_QUERY_MONTADA(4));
			HTP.P(WS_QUERY_MONTADA(5));
			HTP.P(WS_QUERY_MONTADA(6));
		ELSE
			HTP.P('SEM DADOS');
		END IF;
		
    END;

	HTP.P('<style>');

		WS_COUNTER := 0;
		WS_EXTRA   := 0;
		
		IF FUN.GETPROP(PRM_OBJID,'UPLOAD') = 'S' THEN
			WS_EXTRA := WS_EXTRA+1;
		END IF;
		
		IF WS_COUNT_BLINK > 0 THEN
			WS_EXTRA := WS_EXTRA+1;
		END IF;
		
		LOOP
			WS_COUNTER := WS_COUNTER + 1;
			IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
				EXIT;
			END IF;
			DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, WS_COUNTER, RET_COLUNA, 2000);

			IF WS_COUNTER <= RET_MCOL.COUNT THEN
				HTP.P('div#data_list div.corpo table tbody tr td:nth-child('||NVL(RET_MCOL(WS_COUNTER).ORDEM+WS_EXTRA, WS_COUNTER+WS_EXTRA)||') { text-align: '||RET_MCOL(WS_COUNTER).ST_ALINHAMENTO||'; }');
			END IF;
		END LOOP;

	HTP.P('</style>');

    HTP.P('<tbody id="ajax" onclick="browserEvent(event, '''||PRM_OBJID||''', ''edit'');">');
	WS_FIRSTID := 'Y';

	WS_LINHAS := DBMS_SQL.EXECUTE(WS_CURSOR);

	WS_COUNTER := 0;

	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
		EXIT;
	    END IF;

		BEGIN
			WS_CCOLUNA := 1;
			LOOP

			IF  WS_CCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
				EXIT;
			END IF;
			WS_CCOLUNA := WS_CCOLUNA + 1;
			END LOOP;

		EXCEPTION WHEN OTHERS THEN
		EXIT;
	END;

	    WS_COLUNA_ANT(WS_COUNTER) := 'First';
	END LOOP;

	WS_COUNTER := 0;
	LOOP
	    WS_COUNTER := WS_COUNTER+1;
	    IF WS_COUNTER > WS_QUERY_MONTADA.COUNT THEN
	        EXIT;
	    END IF;
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

	    WS_CCOLUNA := 0;
	    WS_CTNULL  := 0;
	    WS_CTCOL   := 0;

		DBMS_SQL.COLUMN_VALUE(WS_CURSOR, 1, RET_COLUNA);

        WS_CONTADOR := WS_CONTADOR+1;
		
		WS_ID_LINHA := TRIM(RET_COLUNA);

		HTP.P('<tr id="B'||REPLACE(REPLACE(REPLACE(REPLACE(RET_COLUNA, CHR(34), CHR(39)), ' ', ''), '/', ''), ':', '')||'-'||WS_CONTADOR||'" class="'||WS_CONTADOR||'">');
        
        





















		
		WS_ID_DOC  := '';
		WS_ID      := '';
		WS_COUNTER := 0;
		
		LOOP
			WS_COUNTER := WS_COUNTER + 1;
			IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
				EXIT;
			END IF;

            IF WS_NCOLUMNS(WS_COUNTER) <> 'DWU_ROWID' AND WS_NCOLUMNS(WS_COUNTER) <> 'DWU_ROWNUM' THEN

				WS_COUNT_CHAVE := 1;
				
				LOOP
					IF RET_MCOL(WS_COUNT_CHAVE).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
						EXIT;
					END IF;
					WS_COUNT_CHAVE := WS_COUNT_CHAVE + 1;
				END LOOP;

				DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_COUNTER, WS_ID_DOC);

                IF RET_MCOL(WS_COUNT_CHAVE).ST_CHAVE = '1' THEN
                    WS_ID := WS_ID||'|'||WS_ID_DOC;
                END IF;
				
			END IF;
		END LOOP;

		BEGIN
			IF FUN.GETPROP(PRM_OBJID,'UPLOAD') = 'S' THEN
				SELECT COUNT(*) INTO WS_COUNT_FILES FROM TAB_DOCUMENTOS WHERE USUARIO = PRM_OBJID||WS_ID;
				HTP.P('<td class="attach" title="'||WS_COUNT_FILES||' '||FUN.LANG('arquivos anexos a linha')||'">');
					HTP.P('<div class="attach-div">');
						HTP.P('<svg class="attach-svg N'||WS_COUNT_FILES||'" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 351.136 351.136" style="enable-background:new 0 0 351.136 351.136;" xml:space="preserve"> <g> <g id="Clips_2_"> <g> <path d="M324.572,42.699c-35.419-35.419-92.855-35.419-128.273,0L19.931,219.066c-26.575,26.575-26.575,69.635,0,96.211 c21.904,21.904,54.942,25.441,80.769,11.224c2.698-0.136,5.351-1.156,7.415-3.197l176.367-176.367 c17.709-17.709,17.709-46.416,0-64.125s-46.416-17.709-64.125,0L76.052,227.116c-4.422,4.422-4.422,11.61,0,16.031 c4.422,4.422,11.61,4.422,16.031,0L236.388,98.843c8.866-8.866,23.219-8.866,32.063,0c8.866,8.866,8.866,23.219,0,32.063 L100.088,299.268c-17.709,17.709-46.416,17.709-64.125,0s-17.709-46.416,0-64.125L212.33,58.73 c26.575-26.575,69.635-26.575,96.211,0c26.575,26.575,26.575,69.635,0,96.211L148.205,315.277c-4.422,4.422-4.422,11.61,0,16.031 c4.422,4.422,11.61,4.422,16.031,0l160.336-160.336C359.991,135.554,359.991,78.118,324.572,42.699z"/> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');	
						
					HTP.P('</span>');
				HTP.P('</td>');
			END IF;
		EXCEPTION WHEN OTHERS THEN
			HTP.P(SQLERRM);
		END;
		
		SELECT COUNT(*) INTO WS_COUNT_BLINK FROM DESTAQUE WHERE CD_OBJETO = REPLACE(PRM_OBJID, ' full', '') AND TIPO_DESTAQUE = 'estrela' AND (CD_USUARIO = WS_USUARIO OR CD_USUARIO = 'DWU');
        
		IF WS_COUNT_BLINK > 0 THEN
	        HTP.P('<td class="destaqueicon">');
	            HTP.P('<svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 19.481 19.481" xmlns:xlink="http://www.w3.org/1999/xlink" enable-background="new 0 0 19.481 19.481"> <g> <path d="m10.201,.758l2.478,5.865 6.344,.545c0.44,0.038 0.619,0.587 0.285,0.876l-4.812,4.169 1.442,6.202c0.1,0.431-0.367,0.77-0.745,0.541l-5.452-3.288-5.452,3.288c-0.379,0.228-0.845-0.111-0.745-0.541l1.442-6.202-4.813-4.17c-0.334-0.289-0.156-0.838 0.285-0.876l6.344-.545 2.478-5.864c0.172-0.408 0.749-0.408 0.921,0z"/> </g> </svg>');
	        HTP.P('</td>');
        END IF;

	    WS_COUNTER := 0;
	    LOOP
			WS_COUNTER := WS_COUNTER + 1;
			IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
				EXIT;
			END IF;

            IF WS_NCOLUMNS(WS_COUNTER) <> 'DWU_ROWID' AND WS_NCOLUMNS(WS_COUNTER) <> 'DWU_ROWNUM' THEN

				WS_CCOLUNA := 1;
				LOOP
					IF RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
						EXIT;
					END IF;
					WS_CCOLUNA := WS_CCOLUNA + 1;
				END LOOP;

				DBMS_SQL.COLUMN_VALUE(WS_CURSOR, WS_COUNTER, RET_COLUNA);

				 IF (RET_MCOL(WS_CCOLUNA).ST_INVISIVEL = 'S' OR RET_MCOL(WS_CCOLUNA).ST_INVISIVEL = 'E') OR (RET_MCOL(WS_CCOLUNA).VIRTUAL_COLUMN = 'YES') THEN
					WS_CLASS := 'inv';
				ELSE
					WS_CLASS := '';
				END IF;
				
                IF RET_MCOL(WS_CCOLUNA).ST_CHAVE = '1' THEN
                    WS_CHAVE := 'class="chave '||WS_CLASS||'"';
                ELSE
                    WS_CHAVE := 'class="'||WS_CLASS||'"';
                END IF;

				IF LENGTH(WS_STYLE) > 0 THEN
					WS_STYLE := ' style="'||WS_STYLE||'"';
				END IF;

				WS_HINT := '';

                BEGIN
				    
	                
					RET_COLUNA_OUT := RET_COLUNA;
					 
					IF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'data' THEN
						RET_COLUNA_OUT := TRIM(SUBSTR(RET_COLUNA_OUT, 1, LENGTH(RET_COLUNA_OUT)-5));
					END IF;
					
					IF LENGTH(TRIM(RET_COLUNA)) > 50 THEN
						WS_COLUNAB := TRIM(SUBSTR(RET_COLUNA_OUT, 1, 50));
					ELSE
						WS_COLUNAB := TRIM(RET_COLUNA_OUT);
					END IF;
					
                EXCEPTION WHEN OTHERS THEN
                    RET_COLUNA := TRIM(RET_COLUNA_OUT);
                END;
                
                BEGIN
	                IF LENGTH(RET_MCOL(WS_CCOLUNA).NM_MASCARA) > 0 THEN
	                    IF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'data' AND NVL(RET_COLUNA, 'N/A') <> 'N/A' THEN
                            BEGIN
                                HTP.P('<td '||WS_STYLE||' '||WS_HINT||' '||WS_CHAVE||' data-d="'||REPLACE(TRIM(RET_COLUNA), CHR(34), '&quot;')||'">'||TO_CHAR(TO_DATE(WS_COLUNAB), 'DD/MM/YYYY')||'</td>');
                            EXCEPTION WHEN OTHERS THEN
                                HTP.P('<td '||WS_STYLE||' '||WS_HINT||' '||WS_CHAVE||' data-d="'||REPLACE(TRIM(RET_COLUNA), CHR(34), '&quot;')||'">'||WS_COLUNAB||'</td>');
                            END;
                        ELSIF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'link' THEN
                            HTP.P('<td '||WS_STYLE||' '||WS_HINT||' '||WS_CHAVE||' data-d="'||TRIM(RET_COLUNA)||'" onclick="if(('''||TRIM(RET_COLUNA)||''').length > 0){ event.stopPropagation(); window.open(''http://'||REPLACE(TRIM(RET_COLUNA), 'http://', '')||'''); }" class="link">'||WS_COLUNAB||'</td>');
                        ELSIF FUN.ISNUMBER(TRIM(RET_COLUNA)) AND RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'number' THEN
	                        HTP.P('<td '||WS_STYLE||' '||WS_HINT||' '||WS_CHAVE||' data-d="'||TRIM(RET_COLUNA)||'">'||TO_CHAR(WS_COLUNAB, RET_MCOL(WS_CCOLUNA).NM_MASCARA, 'NLS_NUMERIC_CHARACTERS = '||CHR(39)||FUN.RET_VAR('POINT')||CHR(39))||'</td>');
                        ELSE
	                        
							IF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'listboxp' THEN
								SELECT CD_CONTEUDO INTO WS_VALOR FROM TABLE(FUN.VPIPE_PAR((RET_MCOL(WS_CCOLUNA).FORMULA))) WHERE TRIM(CD_COLUNA) = TRIM(RET_COLUNA);
							ELSE
								IF LENGTH(TRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA)) > 0 AND (INSTR(RET_MCOL(WS_CCOLUNA).NM_MASCARA, '$[DESC]') > 0 OR INSTR(RET_MCOL(WS_CCOLUNA).NM_MASCARA, '$[COD]') > 0) THEN
									WS_VALOR := TRIM(REPLACE(REPLACE(RET_MCOL(WS_CCOLUNA).NM_MASCARA, '$[DESC]', FUN.CDESC(TRIM(RET_COLUNA), RET_MCOL(WS_CCOLUNA).CD_LIGACAO)), '$[COD]', TRIM(RET_COLUNA)));
								ELSE
								    IF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'ligacaoc' THEN
									    WS_VALOR := TRIM(RET_COLUNA)||' - '||FUN.CDESC(TRIM(RET_COLUNA), RET_MCOL(WS_CCOLUNA).CD_LIGACAO);
									ELSE
                                        WS_VALOR := FUN.CDESC(TRIM(RET_COLUNA), RET_MCOL(WS_CCOLUNA).CD_LIGACAO);
									END IF;
								END IF;
							END IF;
							
							HTP.P('<td '||WS_STYLE||' '||WS_HINT||' '||WS_CHAVE||' data-d="'||TRIM(RET_COLUNA)||'">'||WS_VALOR||'</td>');
	                    END IF;
	                ELSE
                        IF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'data' AND NVL(RET_COLUNA, 'N/A') <> 'N/A' THEN
	                        BEGIN
							    HTP.P('<td '||WS_STYLE||' '||WS_HINT||' '||WS_CHAVE||' data-d="'||TRIM(RET_COLUNA)||'">'||TO_CHAR(TO_DATE(WS_COLUNAB), 'DD/MM/YYYY')||'</td>');
							EXCEPTION WHEN OTHERS THEN 
                                HTP.P('<td '||WS_STYLE||' '||WS_HINT||' '||WS_CHAVE||' data-d="'||TRIM(RET_COLUNA)||'">'||WS_COLUNAB||'</td>');
                            END;
                        ELSIF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'link' THEN
                            HTP.P('<td '||WS_STYLE||' '||WS_HINT||' '||WS_CHAVE||'  data-d="'||TRIM(RET_COLUNA)||'" onclick="if(('''||TRIM(RET_COLUNA)||''').length > 0){ event.stopPropagation(); window.open(''http://'||REPLACE(TRIM(RET_COLUNA), 'http://', '')||'''); }" class="link '||WS_CLASS||'">'||WS_COLUNAB||'</td>');
                        ELSE
						    IF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'listboxp' THEN
							    SELECT CD_CONTEUDO INTO WS_VALOR FROM TABLE(FUN.VPIPE_PAR((RET_MCOL(WS_CCOLUNA).FORMULA))) WHERE TRIM(CD_COLUNA) = TRIM(RET_COLUNA);
							ELSE
							    IF LENGTH(TRIM(RET_MCOL(WS_CCOLUNA).NM_MASCARA)) > 0 AND (INSTR(RET_MCOL(WS_CCOLUNA).NM_MASCARA, '$[DESC]') > 0 OR INSTR(RET_MCOL(WS_CCOLUNA).NM_MASCARA, '$[COD]') > 0) THEN
									WS_VALOR := TRIM(REPLACE(REPLACE(RET_MCOL(WS_CCOLUNA).NM_MASCARA, '$[DESC]', FUN.CDESC(TRIM(RET_COLUNA), RET_MCOL(WS_CCOLUNA).CD_LIGACAO)), '$[COD]', TRIM(RET_COLUNA)));
								ELSE
									IF RET_MCOL(WS_CCOLUNA).TIPO_INPUT = 'ligacaoc' THEN
									    WS_VALOR := TRIM(RET_COLUNA)||' - '||FUN.CDESC(TRIM(RET_COLUNA), RET_MCOL(WS_CCOLUNA).CD_LIGACAO);
									ELSE
                                        WS_VALOR := FUN.CDESC(TRIM(RET_COLUNA), RET_MCOL(WS_CCOLUNA).CD_LIGACAO);
									END IF;
								END IF;
							END IF;
							
							HTP.P('<td '||WS_STYLE||' '||WS_HINT||' '||WS_CHAVE||' data-d="'||TRIM(RET_COLUNA)||'">'||WS_VALOR||'</td>');

	                    END IF;
                    END IF;
                EXCEPTION WHEN OTHERS THEN
					HTP.P('<td '||WS_STYLE||' '||WS_HINT||' '||WS_CHAVE||' data-f=""  data-d="'||TRIM(RET_COLUNA)||'"  data-tipo="'||RET_MCOL(WS_CCOLUNA).TIPO_INPUT||'">'||WS_COLUNAB||'</td>');
                END;

				WS_COLUNA_ANT(WS_COUNTER) := RET_COLUNA;

			END IF;

            IF LENGTH(FUN.CHECK_BLINK_LINHA(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, 'B'||WS_ID_LINHA||'-'||WS_CONTADOR||'', RET_COLUNA, PRM_SCREEN)) > 7 THEN
		        WS_BLINK_LINHA := WS_BLINK_LINHA||FUN.CHECK_BLINK_LINHA(PRM_OBJID, RET_MCOL(WS_CCOLUNA).CD_COLUNA, 'B'||REPLACE(REPLACE(REPLACE(WS_ID_LINHA, ' ', ''), '/', ''), ':', '')||'-'||WS_CONTADOR||'', RET_COLUNA, PRM_SCREEN);
		    END IF;

		END LOOP;
	    WS_FIRSTID := 'N';

		IF WS_BLINK_LINHA <> 'N/A' THEN 
            HTP.P(REPLACE(WS_BLINK_LINHA, 'N/A', ''));
        END IF;
	    WS_BLINK_LINHA := 'N/A';

	    HTP.P('</tr>');
	END LOOP;
	DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);
	HTP.P('</tbody>');
	HTP.P('</table>');
	HTP.P('</div>');

	WS_STYLE   := '';
	WS_TEXTOT  := '';
	WS_PIPE    := '';
	WS_COUNTER := 0;

	LOOP
	    WS_COUNTER := WS_COUNTER + 1;
	    IF  WS_COUNTER > WS_NCOLUMNS.COUNT THEN
		EXIT;
	    END IF;

	    WS_CCOLUNA := 1;
	    LOOP
		BEGIN
		    IF  WS_CCOLUNA = RET_MCOL.COUNT OR RET_MCOL(WS_CCOLUNA).CD_COLUNA = WS_NCOLUMNS(WS_COUNTER) THEN
		        EXIT;
		    END IF;
		EXCEPTION WHEN OTHERS THEN
		    EXIT;
		END;
		WS_CCOLUNA := WS_CCOLUNA + 1;
	    END LOOP;
	END LOOP;

	HTP.P('</div>');

EXCEPTION
    WHEN WS_MOUNT THEN
	    FCL.INICIAR;
    WHEN WS_CLOSE_HTML THEN
	    FCL.POSICIONA_OBJETO('newquery','DWU','DEFAULT','DEFAULT');
	WHEN WS_PARSEERR   THEN

		IF WS_VAZIO THEN
		    HTP.P(WS_NULL);
		ELSE
		    HTP.P(WS_NULL);
		END IF;

	    COMMIT;

		HTP.P('<span style="text-align: center; text-transform: uppercase; font-weight: bold; cursor: move; display: block;">'||FUN.LANG('Sem Dados')||'</span>');
		
		IF WS_ADMIN = 'A' THEN
			HTP.TABLEOPEN( CATTRIBUTES => ' id="'||WS_OBJID||'c" style="width: 500px;"');
				HTP.TABLEROWOPEN( CATTRIBUTES => 'style="background: '||FUN.GETPROP(PRM_OBJID, 'FUNDO_CABECALHO')||'; color: '||FUN.GETPROP(PRM_OBJID, 'FONTE_CABECALHO')||';" border="0" id="'||WS_OBJID||'_tool" ');
					HTP.P('<td colspan="'||WS_NCOLUMNS.COUNT||'" align="left"></td>');
				HTP.TABLEROWCLOSE;
				HTP.TABLEROWOPEN( CATTRIBUTES => ' style="background: '||FUN.GETPROP(PRM_OBJID, 'FUNDO_CABECALHO')||'; color: '||FUN.GETPROP(PRM_OBJID, 'FONTE_CABECALHO')||';" border="0" id="'||WS_OBJID||'_tool" ');
					FCL.TABLEDATAOPEN( CCOLSPAN => WS_NCOLUMNS.COUNT, CALIGN => 'LEFT');
						HTP.P('<div align="center">' || HTF.BOLD( '<FONT size="7">'));
						WS_COUNTER := 0;
						LOOP
							WS_COUNTER := WS_COUNTER + 1;
							IF  WS_COUNTER > WS_QUERY_MONTADA.COUNT THEN
								EXIT;
							END IF;
							HTP.P(WS_QUERY_MONTADA(WS_COUNTER));
						END LOOP;
						HTP.P('</font></div>');
					FCL.TABLEDATACLOSE;
				HTP.TABLEROWCLOSE;
		    HTP.TABLECLOSE;
		END IF;

		HTP.P('<div align="center"><img alt="'||FUN.LANG('alerta')||'" src="'||FUN.R_GIF('warning','PNG')||'"></div>');

		HTP.P('</div>');
	WHEN WS_INVALIDO THEN
	   COMMIT;
	   FCL.NEGADO(FUN.LANG('Parametros Invalidos'));
       HTP.P('');
	WHEN WS_ACESSO THEN
	   FCL.NEGADO(PRM_OBJID);
       HTP.P('');
	WHEN WS_SEMQUERY THEN
	    COMMIT;
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, 'Sem query - BRO', WS_USUARIO, 'ERRO');
        COMMIT;
	WHEN WS_NODATA  THEN
        INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, 'Sem dados - BRO', WS_USUARIO, 'ERRO');
        COMMIT;
	WHEN WS_SEMPERMISSAO THEN
	   FCL.NEGADO(PRM_OBJID||' - '||FUN.LANG('Sem Permiss&atilde;o Para Este Filtro')||'.');
       INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, 'Sem permiss&atilde;o - BRO', WS_USUARIO, 'ERRO');
       COMMIT;
	WHEN OTHERS	THEN
	   COMMIT;
       INSERT INTO BI_LOG_SISTEMA VALUES(SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BRO', WS_USUARIO, 'ERRO');
       COMMIT;
       IF WS_ADMIN = 'A' THEN
			HTP.P(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
		ELSE
			HTP.P('SEM DADOS');
		END IF;
	   HTP.P('</div>');
END MAIN_DATA;

END BRO;
/