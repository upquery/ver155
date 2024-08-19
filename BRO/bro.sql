set scan off
create or replace package body BRO  is

    procedure browser ( prm_objeto varchar2 default null,
                        prm_screen varchar2 default null ) as

		cursor crs_micro_data is
		select nm_tabela as tabela, nvl((select nm_objeto from objetos where cd_objeto = prm_objeto), ds_micro_visao) as descricao
		from MICRO_DATA where nm_micro_data = prm_objeto;

		ws_micro_data crs_micro_data%rowtype;
		
		ws_data_coluna  varchar2(800);
		ws_chave        varchar2(800);
		ws_edit         boolean := true;
		ws_ligacao      varchar2(80);
		ws_count        number := 0;
		ws_ligaclass    varchar2(500);
		ws_countcoluna  number;
		ws_msg			varchar2(100);
		ws_existchave   number;
		ws_first        varchar2(100);
		ws_usuario      varchar2(80);
		ws_admin        varchar2(100);

	begin

	    ws_usuario := gbl.getUsuario;
	    ws_admin   := gbl.getNivel;

	    open crs_micro_data;
		fetch crs_micro_data into ws_micro_data;
		close crs_micro_data;
		
		htp.p('<div id="data_list_menu" data-top="" data-left="" data-height="'||fun.getprop(prm_objeto, 'ALTURA', 'DEFAULT', ws_usuario)||'" data-width="'||fun.getprop(prm_objeto, 'LARGURA', 'DEFAULT', ws_usuario)||'" style="height: '||fun.getprop(prm_objeto, 'ALTURA', 'DEFAULT', ws_usuario)||'px; width: '||fun.getprop(prm_objeto, 'LARGURA', 'DEFAULT', ws_usuario)||'px;" onmouseleave="this.classList.remove(''moving'');" onmousedown="this.classList.add(''moving''); this.setAttribute(''data-top'', event.layerY); this.setAttribute(''data-left'', event.layerX);" onmouseup="this.classList.remove(''moving'');">');
			htp.p('<div id="editb" onmouseleave="resizeBrowser(this, '''||prm_objeto||''');"></div>');
			if fun.getprop(prm_objeto,'MULTI') = 'S' then
				htp.p('<input type="hidden" id="multi-search" value="'||fun.getprop(prm_objeto,'MULTI')||'" />');
			end if;
	        htp.p('<div id="browserbuttons"></div>');
		htp.p('</div>');

		htp.p('<div id="data_list" class="'||prm_objeto||'" data-tabela="'||ws_micro_data.tabela||'">');

		htp.p('<h2 onclick="/*toggleFullScreen();*/">'||fun.SUBPAR(ws_micro_data.descricao, prm_screen)||'</h2>');

		select count(*) into ws_countcoluna from data_coluna where cd_micro_data = prm_objeto;
			if ws_countcoluna > 0 then
				select tipo_input into ws_ligacao from (select tipo_input from data_coluna where cd_micro_data = prm_objeto order by st_chave desc) where rownum = 1;
			end if;

		select count(st_chave) into ws_existchave from data_coluna where cd_micro_data = prm_objeto and st_chave = '1' or st_chave = 1;

        htp.p('<div class="menu '||ws_ligacao||'">');
			
		if ws_existchave <> 0 then

			select count(*) into ws_count from object_attrib where cd_object = prm_objeto and cd_prop = 'PERMISSAOAD' and ws_usuario in (select * from table((fun.vpipe(propriedade))));

            if ws_count = 0 then
			
                htp.p('<a class="buttonbrowser" title="'||fun.lang('adicionar linha')||'" onclick="browserEvent(event, '''||prm_objeto||''', ''new'');"><svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 491.86 491.86" style="enable-background:new 0 0 491.86 491.86;" xml:space="preserve"> <g> <g> <path d="M465.167,211.614H280.245V26.691c0-8.424-11.439-26.69-34.316-26.69s-34.316,18.267-34.316,26.69v184.924H26.69 C18.267,211.614,0,223.053,0,245.929s18.267,34.316,26.69,34.316h184.924v184.924c0,8.422,11.438,26.69,34.316,26.69 s34.316-18.268,34.316-26.69V280.245H465.17c8.422,0,26.69-11.438,26.69-34.316S473.59,211.614,465.167,211.614z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg></a>');
		    
            end if;

		end if;
					    
            if ws_admin = 'A' then
                htp.p('<a class="buttonbrowser" title="'||fun.lang('alterar colunas')||'" onclick="browserEvent(event, '''||prm_objeto||''', ''colunas'');"><svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"width="433.5px" height="433.5px" viewBox="0 0 433.5 433.5" style="enable-background:new 0 0 433.5 433.5;" xml:space="preserve"> <g> <g id="view-column"> <path d="M153,382.5h127.5V51H153V382.5z M0,382.5h127.5V51H0V382.5z M306,51v331.5h127.5V51H306z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg></a>');
            end if;
            
            if ws_admin = 'A' then
            --  htp.p('<a class="buttonbrowser" title="'||fun.lang('propriedades')||'" onclick="loadAttrib(''properties'', ''prm_id='||prm_objeto||''', ''bro'');"><svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 268.765 268.765" style="enable-background:new 0 0 268.765 268.765;" xml:space="preserve"> <g id="Settings"> <g> <path style="fill-rule:evenodd;clip-rule:evenodd;" d="M267.92,119.461c-0.425-3.778-4.83-6.617-8.639-6.617 c-12.315,0-23.243-7.231-27.826-18.414c-4.682-11.454-1.663-24.812,7.515-33.231c2.889-2.641,3.24-7.062,0.817-10.133 c-6.303-8.004-13.467-15.234-21.289-21.5c-3.063-2.458-7.557-2.116-10.213,0.825c-8.01,8.871-22.398,12.168-33.516,7.529 c-11.57-4.867-18.866-16.591-18.152-29.176c0.235-3.953-2.654-7.39-6.595-7.849c-10.038-1.161-20.164-1.197-30.232-0.08 c-3.896,0.43-6.785,3.786-6.654,7.689c0.438,12.461-6.946,23.98-18.401,28.672c-10.985,4.487-25.272,1.218-33.266-7.574 c-2.642-2.896-7.063-3.252-10.141-0.853c-8.054,6.319-15.379,13.555-21.74,21.493c-2.481,3.086-2.116,7.559,0.802,10.214 c9.353,8.47,12.373,21.944,7.514,33.53c-4.639,11.046-16.109,18.165-29.24,18.165c-4.261-0.137-7.296,2.723-7.762,6.597 c-1.182,10.096-1.196,20.383-0.058,30.561c0.422,3.794,4.961,6.608,8.812,6.608c11.702-0.299,22.937,6.946,27.65,18.415 c4.698,11.454,1.678,24.804-7.514,33.23c-2.875,2.641-3.24,7.055-0.817,10.126c6.244,7.953,13.409,15.19,21.259,21.508 c3.079,2.481,7.559,2.131,10.228-0.81c8.04-8.893,22.427-12.184,33.501-7.536c11.599,4.852,18.895,16.575,18.181,29.167 c-0.233,3.955,2.67,7.398,6.595,7.85c5.135,0.599,10.301,0.898,15.481,0.898c4.917,0,9.835-0.27,14.752-0.817 c3.897-0.43,6.784-3.786,6.653-7.696c-0.451-12.454,6.946-23.973,18.386-28.657c11.059-4.517,25.286-1.211,33.281,7.572 c2.657,2.89,7.047,3.239,10.142,0.848c8.039-6.304,15.349-13.534,21.74-21.494c2.48-3.079,2.13-7.559-0.803-10.213 c-9.353-8.47-12.388-21.946-7.529-33.524c4.568-10.899,15.612-18.217,27.491-18.217l1.662,0.043 c3.853,0.313,7.398-2.655,7.865-6.588C269.044,139.917,269.058,129.639,267.92,119.461z M134.595,179.491 c-24.718,0-44.824-20.106-44.824-44.824c0-24.717,20.106-44.824,44.824-44.824c24.717,0,44.823,20.107,44.823,44.824 C179.418,159.385,159.312,179.491,134.595,179.491z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
				htp.p('<a class="buttonbrowser" title="'||fun.lang('propriedades')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||''');"><svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 268.765 268.765" style="enable-background:new 0 0 268.765 268.765;" xml:space="preserve"> <g id="Settings"> <g> <path style="fill-rule:evenodd;clip-rule:evenodd;" d="M267.92,119.461c-0.425-3.778-4.83-6.617-8.639-6.617 c-12.315,0-23.243-7.231-27.826-18.414c-4.682-11.454-1.663-24.812,7.515-33.231c2.889-2.641,3.24-7.062,0.817-10.133 c-6.303-8.004-13.467-15.234-21.289-21.5c-3.063-2.458-7.557-2.116-10.213,0.825c-8.01,8.871-22.398,12.168-33.516,7.529 c-11.57-4.867-18.866-16.591-18.152-29.176c0.235-3.953-2.654-7.39-6.595-7.849c-10.038-1.161-20.164-1.197-30.232-0.08 c-3.896,0.43-6.785,3.786-6.654,7.689c0.438,12.461-6.946,23.98-18.401,28.672c-10.985,4.487-25.272,1.218-33.266-7.574 c-2.642-2.896-7.063-3.252-10.141-0.853c-8.054,6.319-15.379,13.555-21.74,21.493c-2.481,3.086-2.116,7.559,0.802,10.214 c9.353,8.47,12.373,21.944,7.514,33.53c-4.639,11.046-16.109,18.165-29.24,18.165c-4.261-0.137-7.296,2.723-7.762,6.597 c-1.182,10.096-1.196,20.383-0.058,30.561c0.422,3.794,4.961,6.608,8.812,6.608c11.702-0.299,22.937,6.946,27.65,18.415 c4.698,11.454,1.678,24.804-7.514,33.23c-2.875,2.641-3.24,7.055-0.817,10.126c6.244,7.953,13.409,15.19,21.259,21.508 c3.079,2.481,7.559,2.131,10.228-0.81c8.04-8.893,22.427-12.184,33.501-7.536c11.599,4.852,18.895,16.575,18.181,29.167 c-0.233,3.955,2.67,7.398,6.595,7.85c5.135,0.599,10.301,0.898,15.481,0.898c4.917,0,9.835-0.27,14.752-0.817 c3.897-0.43,6.784-3.786,6.653-7.696c-0.451-12.454,6.946-23.973,18.386-28.657c11.059-4.517,25.286-1.211,33.281,7.572 c2.657,2.89,7.047,3.239,10.142,0.848c8.039-6.304,15.349-13.534,21.74-21.494c2.48-3.079,2.13-7.559-0.803-10.213 c-9.353-8.47-12.388-21.946-7.529-33.524c4.568-10.899,15.612-18.217,27.491-18.217l1.662,0.043 c3.853,0.313,7.398-2.655,7.865-6.588C269.044,139.917,269.058,129.639,267.92,119.461z M134.595,179.491 c-24.718,0-44.824-20.106-44.824-44.824c0-24.717,20.106-44.824,44.824-44.824c24.717,0,44.823,20.107,44.823,44.824 C179.418,159.385,159.312,179.491,134.595,179.491z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');

		    end if;
            
			select count(*) into ws_count from object_attrib where cd_object = prm_objeto and cd_prop = 'PERMISSAONOFILTER' and ws_usuario in (select * from table((fun.vpipe(propriedade))));
            if ws_count = 0 or ws_admin = 'A' then
                htp.p('<a class="buttonbrowser" title="'||fun.lang('alterar filtros')||'" onclick="browserEvent(event, '''||prm_objeto||''', ''filtros'', '''||ws_micro_data.tabela||''');"><svg style="stroke-width: 2px; stroke: #FFF;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="56.805px" height="56.805px" viewBox="0 0 56.805 56.805" style="enable-background:new 0 0 56.805 56.805;" xml:space="preserve"> <g> <g id="_x32_7"> <g> <path d="M56.582,4.352c-0.452-1.092-1.505-1.796-2.685-1.796H2.908c-1.18,0-2.233,0.704-2.685,1.796 c-0.451,1.091-0.204,2.336,0.63,3.171l20.177,20.21V53.02c0,0.681,0.55,1.229,1.229,1.229c0.68,0,1.229-0.549,1.229-1.229V27.223 c0-0.327-0.13-0.64-0.36-0.87L2.591,5.782c-0.184-0.185-0.14-0.385-0.098-0.487C2.537,5.19,2.646,5.019,2.908,5.019h50.99 c0.26,0,0.37,0.173,0.414,0.276c0.042,0.103,0.086,0.303-0.099,0.487L33.679,26.353c-0.23,0.23-0.36,0.543-0.36,0.87v18.412 c0,0.681,0.55,1.229,1.229,1.229c0.681,0,1.229-0.55,1.229-1.229V27.732l20.177-20.21C56.785,6.688,57.033,5.443,56.582,4.352z"></path> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg></a>');
            end if;
			
			select count(*) into ws_count from object_attrib where cd_object = prm_objeto and cd_prop = 'PERMISSAODESTAQUE' and ws_usuario in (select * from table((fun.vpipe(propriedade))));
            if ws_count = 0 or ws_admin = 'A' then
				htp.p('<a class="buttonbrowser" title="'||fun.lang('alterar destaques')||'" onclick="browserEvent(event, '''||prm_objeto||''', ''destaques'', '''||ws_micro_data.tabela||''');"><svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 19.481 19.481" xmlns:xlink="http://www.w3.org/1999/xlink" enable-background="new 0 0 19.481 19.481"> <g> <path d="m10.201,.758l2.478,5.865 6.344,.545c0.44,0.038 0.619,0.587 0.285,0.876l-4.812,4.169 1.442,6.202c0.1,0.431-0.367,0.77-0.745,0.541l-5.452-3.288-5.452,3.288c-0.379,0.228-0.845-0.111-0.745-0.541l1.442-6.202-4.813-4.17c-0.334-0.289-0.156-0.838 0.285-0.876l6.344-.545 2.478-5.864c0.172-0.408 0.749-0.408 0.921,0z"></path> </g> </svg></a>');
			end if;

			htp.p('<a id="excel-browser" class="buttonbrowser" onclick="browserToExcel('''||prm_objeto||''');" title="exportar relat&oacute;rio">');
				htp.p('<svg style="margin: 1px 0; width: auto; height: 22px; pointer-events: none;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 512 512" style="enable-background:new 0 0 512 512;" xml:space="preserve"> <path style="fill:#ECEFF1;" d="M496,432.011H272c-8.832,0-16-7.168-16-16s0-311.168,0-320s7.168-16,16-16h224 c8.832,0,16,7.168,16,16v320C512,424.843,504.832,432.011,496,432.011z"/> <g> <path style="fill:#388E3C;" d="M336,176.011h-64c-8.832,0-16-7.168-16-16s7.168-16,16-16h64c8.832,0,16,7.168,16,16 S344.832,176.011,336,176.011z"/> <path style="fill:#388E3C;" d="M336,240.011h-64c-8.832,0-16-7.168-16-16s7.168-16,16-16h64c8.832,0,16,7.168,16,16 S344.832,240.011,336,240.011z"/> <path style="fill:#388E3C;" d="M336,304.011h-64c-8.832,0-16-7.168-16-16s7.168-16,16-16h64c8.832,0,16,7.168,16,16 S344.832,304.011,336,304.011z"/> <path style="fill:#388E3C;" d="M336,368.011h-64c-8.832,0-16-7.168-16-16s7.168-16,16-16h64c8.832,0,16,7.168,16,16 S344.832,368.011,336,368.011z"/> <path style="fill:#388E3C;" d="M432,176.011h-32c-8.832,0-16-7.168-16-16s7.168-16,16-16h32c8.832,0,16,7.168,16,16 S440.832,176.011,432,176.011z"/> <path style="fill:#388E3C;" d="M432,240.011h-32c-8.832,0-16-7.168-16-16s7.168-16,16-16h32c8.832,0,16,7.168,16,16 S440.832,240.011,432,240.011z"/> <path style="fill:#388E3C;" d="M432,304.011h-32c-8.832,0-16-7.168-16-16s7.168-16,16-16h32c8.832,0,16,7.168,16,16 S440.832,304.011,432,304.011z"/> <path style="fill:#388E3C;" d="M432,368.011h-32c-8.832,0-16-7.168-16-16s7.168-16,16-16h32c8.832,0,16,7.168,16,16 S440.832,368.011,432,368.011z"/> </g> <path style="fill:#2E7D32;" d="M282.208,19.691c-3.648-3.04-8.544-4.352-13.152-3.392l-256,48C5.472,65.707,0,72.299,0,80.011v352 c0,7.68,5.472,14.304,13.056,15.712l256,48c0.96,0.192,1.952,0.288,2.944,0.288c3.712,0,7.328-1.28,10.208-3.68 c3.68-3.04,5.792-7.584,5.792-12.32v-448C288,27.243,285.888,22.731,282.208,19.691z"/> <path style="fill:#FAFAFA;" d="M220.032,309.483l-50.592-57.824l51.168-65.792c5.44-6.976,4.16-17.024-2.784-22.464 c-6.944-5.44-16.992-4.16-22.464,2.784l-47.392,60.928l-39.936-45.632c-5.856-6.72-15.968-7.328-22.56-1.504 c-6.656,5.824-7.328,15.936-1.504,22.56l44,50.304L83.36,310.187c-5.44,6.976-4.16,17.024,2.784,22.464 c2.944,2.272,6.432,3.36,9.856,3.36c4.768,0,9.472-2.112,12.64-6.176l40.8-52.48l46.528,53.152 c3.168,3.648,7.584,5.504,12.032,5.504c3.744,0,7.488-1.312,10.528-3.968C225.184,326.219,225.856,316.107,220.032,309.483z"/> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
            htp.p('</a>');

            htp.p('<span id="bro-menu">');
			    bro.menu(prm_objeto);
			htp.p('</span>');
 
			htp.p('<select id="browser-condicao" onchange="var campo = document.getElementById(''data-valor''); if(this.value == ''nulo'' || this.value == ''nnulo''){ campo.value = ''0''; campo.parentNode.classList.add(''nulo''); } else { campo.value = ''''; campo.parentNode.classList.remove(''nulo''); }">');
			    htp.p('<option value="igual">'||fun.lang('Igual')||'</option>');
                htp.p('<option value="maior">'||fun.lang('Igual ou Maior')||'</option>');
                htp.p('<option value="semelhante">'||fun.lang('Semelhante')||'</option>');
                htp.p('<option value="diferente">'||fun.lang('Diferente')||'</option>');
				htp.p('<option value="nulo">'||fun.lang('Nulo')||'</option>');
				htp.p('<option value="nnulo">'||fun.lang('N&atilde;o Nulo')||'</option>');
			htp.p('</select>');

			select cd_coluna into ws_first from (select cd_coluna from data_coluna where cd_micro_data = prm_objeto order by st_chave desc) where rownum = 1;

			fcl.fakeoption(ws_first, 'Lista de colunas', '', 'lista-ligacao-browser', 'N', 'N', ws_micro_data.tabela, prm_adicional => prm_objeto);
			htp.p('<input type="text" id="data-valor" onkeypress="if(event.which == 13){ this.nextElementSibling.click(); }" style="padding: 2px 26px 0 2px; width: 140px;">');

			htp.p('<img onclick="browserSearch('''');" title="pesquisar" src="'||fun.R_GIF('lupe', 'PNG')||'" />');
			--htp.p('<span class="filtros">F</span>');

		htp.p('</div>');

		htp.p('<div class="menu right">');
			htp.p('<div class="arrows">');
			    -- Alterado para passar a quantidade de registro da primeira página corretamente - 07/02/2022 
				--htp.p('<a class="backstart" onclick="if(parseInt(document.getElementById(''browser-page'').getAttribute(''data-pagina'')) > 1){ browserSearch(''<<'', document.getElementById(''ajax'').firstElementChild.className); } else { alerta(''feed-fixo'', '''||fun.lang('Primeira p&aacute;gina')||'!''); }" title="'||fun.lang('Voltar ao in&iacute;cio')||'"><img src="'||fun.R_GIF('seta', 'PNG')||'" /><img src="'||fun.R_GIF('seta', 'PNG')||'" /></a>');
				htp.p('<a class="backstart" onclick="if(parseInt(document.getElementById(''browser-page'').getAttribute(''data-pagina'')) > 1){ browserSearch(''<<'', 1); } else { alerta(''feed-fixo'', '''||fun.lang('Primeira p&aacute;gina')||'!''); }" title="'||fun.lang('Voltar ao in&iacute;cio')||'"><img src="'||fun.R_GIF('seta', 'PNG')||'" /><img src="'||fun.R_GIF('seta', 'PNG')||'" /></a>');	
				htp.p('<a class="backpage" onclick="if(parseInt(document.getElementById(''browser-page'').getAttribute(''data-pagina'')) > 1){ browserSearch(''<'', document.getElementById(''ajax'').firstElementChild.className); } else { alerta(''feed-fixo'', '''||fun.lang('Primeira p&aacute;gina')||'!''); }" title="'||fun.lang('Voltar uma p&aacute;gina')||'"><img src="'||fun.R_GIF('seta', 'PNG')||'" /></a>');
				htp.p('<select id="linhas" type="number" title="numero de linhas" onchange="if(document.getElementById(''ajax'').firstElementChild){ var origem = document.getElementById(''ajax'').firstElementChild.className; } else { var origem = 0; } ajax(''fly'', ''alter_attrib'', ''prm_objeto='||prm_objeto||'&prm_prop=LINHAS&prm_value=''+this.value+''&prm_usuario='||ws_usuario||''', true); browserSearch(''<<'', origem);"/>');
                    htp.p('<option value="50">50 linhas</option>');
                    if fun.getprop(prm_objeto, 'LINHAS', 'DEFAULT', ws_usuario) = '100' then
					    htp.p('<option value="100" selected>100 linhas</option>');
                    else
                        htp.p('<option value="100">100 linhas</option>');
                    end if;
					if fun.getprop(prm_objeto, 'LINHAS', 'DEFAULT', ws_usuario) = '200' then
					    htp.p('<option value="200" selected>200 linhas</option>');
                    else
                        htp.p('<option value="200">200 linhas</option>');
                    end if;
					if fun.getprop(prm_objeto, 'LINHAS', 'DEFAULT', ws_usuario) = '400' then
					    htp.p('<option value="400" selected>400 linhas</option>');
                    else
                        htp.p('<option value="400">400 linhas</option>');
                    end if;
				htp.p('</select>');
				htp.p('<a onclick="if(document.getElementById(''browser-page'').getAttribute(''data-pagina'') != document.getElementById(''browser-page'').className){ if(document.getElementById(''ajax'').lastElementChild){ var origem = document.getElementById(''ajax'').lastElementChild.className; } else { var origem = 0; } browserSearch(''>'', origem); } else { alerta(''feed-fixo'', '''||fun.lang('&Uacute;ltima p&aacute;gina')||'!''); }"style="transform: rotate(-90deg); margin: 3px 5px;" title="'||fun.lang('Avan&ccedil;ar uma p&aacute;gina')||'"><img src="'||fun.R_GIF('seta', 'PNG')||'" /></a>');
				-- Alterado para passar a quantidade de registro da última página corretamente - 07/02/2022 
				--htp.p('<a onclick="if(document.getElementById(''browser-page'').getAttribute(''data-pagina'') != document.getElementById(''browser-page'').className){ if(document.getElementById(''ajax'').lastElementChild){ var origem = document.getElementById(''ajax'').lastElementChild.className; } else { var origem = 0; } browserSearch(''>>'', origem); } else { alerta(''feed-fixo'', '''||fun.lang('&Uacute;ltima p&aacute;gina')||'!''); }"style="transform: rotate(-90deg); margin: 0 5px;" title="'||fun.lang('Avan&ccedil;ar para a &uacute;ltima p&aacute;gina')||'"><img src="'||fun.R_GIF('seta', 'PNG')||'" /><img src="'||fun.R_GIF('seta', 'PNG')||'" /></a>');
				htp.p('<a onclick=" if(document.getElementById(''browser-page'').getAttribute(''data-pagina'') != document.getElementById(''browser-page'').className){ if(document.getElementById(''linhas'')) { var limite = document.getElementById(''linhas'').value, totalpg = document.getElementById(''browser-page'').className; origem = (totalpg - 1) * limite;  } else { var origem = 0; } browserSearch(''>>'', origem); } else { alerta(''feed-fixo'', '''||fun.lang('&Uacute;ltima p&aacute;gina')||'!''); }"style="transform: rotate(-90deg); margin: 0 5px;" title="'||fun.lang('Avan&ccedil;ar para a &uacute;ltima p&aacute;gina')||'"><img src="'||fun.R_GIF('seta', 'PNG')||'" /><img src="'||fun.R_GIF('seta', 'PNG')||'" /></a>');
			htp.p('</div>');

            htp.p('<input class="font-size" value="'||fun.getprop(prm_objeto, 'SIZE', 'DEFAULT', ws_usuario)||'" type="range" step="1" min="10" max="20" onchange="ajax(''fly'', ''alter_attrib'', ''prm_objeto='||prm_objeto||'&prm_prop=SIZE&prm_value=''+this.value+''&prm_usuario='||ws_usuario||''', true);" oninput="document.querySelector(''.header'').style.setProperty(''font-size'', this.value+''px''); document.querySelector(''.corpo'').style.setProperty(''font-size'', this.value+''px''); /*this.nextElementSibling.value = this.value+''px'';*/"/>');
            htp.p('<input class="font-size-number" type="text" readonly value="14px"/>');

		htp.p('</div>');

		htp.p('<div class="menu" id="filtros-acumulados"></div>');
			begin
								
				if ws_countcoluna > 0 then
					bro.main_data(prm_objeto, ws_data_coluna, ws_micro_data.tabela,prm_screen, '');
				else
					if ws_admin = 'A' then
						htp.p('<div id="msgtexto">');
							htp.p('<tr class="msgtexto">');
								htp.p('<td>Nenhuma coluna declarada!</td>');
							htp.p('</tr>');
						htp.p('</div>');
					end if;
				end if;
			end;

		htp.p('</div>');
	exception when others then
		if ws_admin = 'A' then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
		end if;

	end browser;

	procedure browserButtons  ( prm_tipo varchar2 default null,
	                            prm_visao varchar2 default null,
	                            prm_chave varchar2 default null ) as
	
	    ws_count_ex number;
		ws_count_ed number;
		ws_count_ad number;
		ws_usuario  varchar2(80);

	begin

	    ws_usuario := gbl.getUsuario;
	
	    select count(*) into ws_count_ex from object_attrib where cd_object = prm_visao and cd_prop = 'PERMISSAOEX' and ws_usuario in (select * from table((fun.vpipe(propriedade))));
	    select count(*) into ws_count_ed from object_attrib where cd_object = prm_visao and cd_prop = 'PERMISSAOED' and ws_usuario in (select * from table((fun.vpipe(propriedade))));
	    select count(*) into ws_count_ad from object_attrib where cd_object = prm_visao and cd_prop = 'PERMISSAOAD' and ws_usuario in (select * from table((fun.vpipe(propriedade))));


		    case prm_tipo
				when 'update' then
					
					if ws_count_ed = 0 then
					    htp.p('<a class="link ac1" title="ctrl + ENTER" onclick="save(''browseredit''); if(document.querySelector(''.selectedbline'')){ document.querySelector(''.selectedbline'').classList.remove(''selectedbline''); } selectedb = '''';">'||fun.lang('SALVAR')||'</a>');
					end if;
					
					if ws_count_ex = 0 then
					    htp.p('<a class="link ac2" style="background: #DD2222; color: #FFFFFF;" onclick="var dis = this; curtain(); if(confirm(''Tem certeza que gostaria de excluir a linha?'')){ loading(); call(''browserExclude'', ''prm_chave=''+document.getElementById(''browser-chave-valores'').value+''&prm_campo=''+document.getElementById(''browser-campos'').value+''&prm_visao='||prm_visao||''', ''bro'').then(function(resposta){ loading(); if(resposta.indexOf(''OK'') != -1){ alerta(''feed-fixo'', TR_EX); browserSearch(''BUSCA''); browserMenu(dis.parentNode.parentNode); } else { alerta(''feed-fixo'', resposta.replace(''ERROR: '', '''')); } }); }">'||fun.lang('EXCLUIR')||'</a>');
		            end if;
					
				when 'insert' then
		            if ws_count_ad = 0 then
					    htp.p('<a class="link ac1" onclick="save(''browseradd''); if(document.querySelector(''.selectedbline'')){ document.querySelector(''.selectedbline'').classList.remove(''selectedbline''); } selectedb = '''';">'||fun.lang('ADICIONAR')||'</a>');
	                end if;
			else
		        htp.p('');
		    end case;

        htp.p('<a class="link ac3" onclick="curtain(); selectedb = ''''; browserMenu(this.parentNode.parentNode);">'||fun.lang('FECHAR')||'</a>');

	end browserButtons;


	procedure browserEdit ( prm_obj    varchar2 default null,
	                        prm_chave  varchar2 default null,
							prm_campo  varchar2 default null,
                            prm_tabela varchar2 default null ) as


	    cursor crs_dados is

		SELECT cd_coluna, nm_rotulo, nm_mascara, st_chave, st_default, cd_ligacao, formula, st_alinhamento, ds_alinhamento, tipo_input, column_id, tamanho, st_branco, data_length, nvl(ordem, 99) as ordem, nvl(permissao, 'W') as permissao, st_invisivel, virtual_column
        FROM data_coluna, all_tab_cols
		WHERE cd_micro_data = trim(prm_obj)
        and column_name = cd_coluna and
        trim(table_name) = trim(prm_tabela)
		order by column_id, st_chave, ordem, permissao;
		
	    ws_dado crs_dados%rowtype;

		ws_sql  varchar2(8000);
		
		prm_linhas DBMS_SQL.VARCHAR2_TABLE;

		ws_count         number := 0;
		ws_tab           number := 0;
		ws_notfound      exception;
		ws_mascara       varchar2(400) := '';
		ws_linhas        number;
		ws_lista         varchar2(4000);
		ws_cursor	     integer;
		ws_valor         varchar2(4000) := '';
		ws_read          varchar2(4000);
		ws_event         varchar2(4000);
        ws_chave         number;
        ws_counter       number;
        ws_invisivel     varchar2(800);
        ws_obrigatorio   varchar2(20) := '';
        ws_count_per     number;
		ws_html_d        varchar2(4000);
		ws_html_v        varchar2(4000);
		ws_nls           varchar2(20);
		ws_tamanho		 number;
        ws_usuario       varchar2(80);
	begin

	    ws_usuario := gbl.getUsuario;
	
	    SELECT value into ws_nls FROM nls_database_parameters WHERE  parameter = 'NLS_DATE_FORMAT';
	
	    --usando pra verificar se &eacute; nova linha
	    if length(prm_chave) > 0 then

		    bro.GET_LINHA(prm_tabela, prm_chave, prm_campo, prm_linhas, prm_obj);
			
			if  substr(prm_linhas(1),1,10) = '%ERR%-UPQ-' then
				raise ws_notfound;
		    end if;

			htp.p('<input id="browser-chave-valores" type="hidden" value="'||trim(prm_chave)||'"/>');
			
		else
		
            htp.p('<input id="browser-chave-valores" type="hidden" value=""/>');
			
        end if;

		htp.p('<input id="browser-tabela" type="hidden" value="'||prm_obj||'"/>');
		htp.p('<input id="browser-campos" type="hidden" value="'||prm_campo||'"/>');
		
	    htp.p('<ul id="browseredit">');

			open crs_dados;
				loop
					fetch crs_dados into ws_dado;
					exit when crs_dados%notfound;

                    begin

					ws_count := ws_count+1;

                    --usando pra verificar se é nova linha
	                if length(prm_chave) > 0 then

		                ws_valor := prm_linhas(ws_count);
		            else

                        ws_valor := fun.xexec(ws_dado.st_default, '');

                    end if;
					
					if ws_dado.tipo_input = 'data' or ws_dado.tipo_input = 'datatime' then
					
						begin
							ws_valor := to_char(to_date(ws_valor, ws_nls), 'DD/MM/YYYY HH24:MI');
						exception when others then
						    ws_valor := ws_valor;
						end;
					end if;
                    
                    select count(*) into ws_count_per from table((fun.vpipe(ws_dado.permissao)));
                    if ws_dado.permissao = 'R' then
                        ws_read := ' disabled ';
                    else
	                    if ws_count_per <> 0 and ws_dado.permissao <> 'W' then
	                        select count(*) into ws_count_per from table((fun.vpipe(ws_dado.permissao))) where column_value = ws_usuario;
						    if ws_count_per = 0 then
						        ws_read := ' disabled ';
						    else
						        ws_read := ' ';
						    end if;
						else
						    ws_read := ' ';
						end if;
				    end if;

				    
                    ws_chave := ws_dado.st_chave;
                    
                    if (ws_dado.st_invisivel = 'S' or ws_dado.st_invisivel = 'B') or (ws_dado.virtual_column = 'YES') then
                        ws_invisivel := 'display: none;';
						ws_tab := '';
                    else
					    ws_tab := ws_dado.ordem;
                        ws_invisivel := '';
                    end if;
                    
                    if instr(prm_campo, ws_dado.cd_coluna) > 0 or ws_dado.st_branco = '1' then
                        ws_obrigatorio := 'data-obrigatorio="*"';
                    else
                        ws_obrigatorio := '';
                    end if;

					if length(prm_chave) > 0 then
					    
					    if ws_dado.tipo_input = 'data' then
                            begin
							    ws_html_d := trim(substr(ws_valor, 1, length(ws_valor)-5));
							    ws_html_v := trim(substr(ws_valor, 1, length(ws_valor)-5));
							exception when others then
                                ws_html_d := trim(ws_valor);
							    ws_html_v := trim(ws_valor);
							end;
							
							htp.p('<li data-chave="'||ws_chave||'" '||ws_obrigatorio||' style="order: '||ws_dado.ordem||'; '||ws_invisivel||'" data-tipo="'||ws_dado.tipo_input||'" data-d="'||replace(ws_html_d, chr(34), '$[DQUOTE]')||'" data-v="'||replace(ws_html_v, chr(34), '$[DQUOTE]')||'" data-c="'||ws_dado.cd_coluna||'">');

					    else
                            if ws_dado.tipo_input = 'sequence' and nvl(prm_chave, 'N/A') = 'N/A' then 
                                ws_html_d := trim(ws_valor);
								ws_html_v := '0';
                            else
                                ws_html_d := trim(ws_valor);
								ws_html_v := trim(ws_valor);
                            end if;
							
							if ws_dado.tipo_input = 'sequence' or ws_chave = 1 then 
								htp.p('<li class="readonly" data-chave="'||ws_chave||'" '||ws_obrigatorio||' style="order: '||ws_dado.ordem||'; '||ws_invisivel||'" data-tipo="'||ws_dado.tipo_input||'" data-d="'||replace(ws_html_d, chr(34), '$[DQUOTE]')||'" data-v="'||replace(ws_html_v, chr(34), '$[DQUOTE]')||'" data-c="'||ws_dado.cd_coluna||'">');
							else
							    htp.p('<li data-chave="'||ws_chave||'" '||ws_obrigatorio||' style="order: '||ws_dado.ordem||'; '||ws_invisivel||'" data-tipo="'||ws_dado.tipo_input||'" data-d="'||replace(ws_html_d, chr(34), '$[DQUOTE]')||'" data-v="'||replace(ws_html_v, chr(34), '$[DQUOTE]')||'" data-c="'||ws_dado.cd_coluna||'">');
                            end if;

                        end if;

                    else
                        if ws_dado.tipo_input = 'data' then
	                        begin
							    ws_html_d := trim(substr(ws_valor, 1, length(ws_valor)-5));
							    ws_html_v := trim(substr(ws_valor, 1, length(ws_valor)-5));
							exception when others then
                                ws_html_d := trim(ws_valor);
							    ws_html_v := trim(ws_valor);
							end;
							
							htp.p('<li data-tipo="'||ws_dado.tipo_input||'" data-chave="'||ws_chave||'" '||ws_obrigatorio||' style="order: '||ws_dado.ordem||';'||ws_invisivel||'" data-d="'||replace(ws_html_d, chr(34), '$[DQUOTE]')||'" data-v="'||replace(ws_html_v, chr(34), '$[DQUOTE]')||'" data-c="'||ws_dado.cd_coluna||'">');

                        else
                            if ws_dado.tipo_input = 'sequence' then 
                                ws_html_d := trim(ws_valor);
								ws_html_v := '0';
                            else
                                ws_html_d := trim(ws_valor);
								ws_html_v := trim(ws_valor);
                            end if;
							
							if ws_dado.tipo_input = 'textarea' then
						        ws_invisivel := ws_invisivel||' flex-basis: 100%;';
						    end if;
							

                            if ws_dado.tipo_input = 'sequence' then 
							    htp.p('<li class="invisible" data-tipo="'||ws_dado.tipo_input||'" data-chave="'||ws_chave||'"  style="order: '||ws_dado.ordem||';'||ws_invisivel||'" data-d="'||replace(ws_html_d, chr(34), '$[DQUOTE]')||'" data-v="'||replace(ws_html_v, chr(34), '$[DQUOTE]')||'" data-c="'||ws_dado.cd_coluna||'">');
                            else
                                htp.p('<li data-tipo="'||ws_dado.tipo_input||'" data-chave="'||ws_chave||'" '||ws_obrigatorio||' style="order: '||ws_dado.ordem||';'||ws_invisivel||'" data-d="'||replace(ws_html_d, chr(34), '$[DQUOTE]')||'" data-v="'||replace(ws_html_v, chr(34), '$[DQUOTE]')||'" data-c="'||ws_dado.cd_coluna||'">');

							end if;
							
                        end if;

                    end if;
					    
						htp.p('<span>'||ws_dado.nm_rotulo||'</span>');

						if (length(prm_chave) > 0 and ws_chave <> 0) or ws_dado.ds_alinhamento = 'xxx' then
						    
							    ws_html_v := fun.cdesc(trim(ws_valor), ws_dado.cd_ligacao);
								if ws_dado.tipo_input = 'data' then
								    ws_html_v := trim(substr(ws_html_v, 1, length(ws_html_v)-5));
								end if;
						   
							    htp.p('<input maxlength="'||ws_dado.tamanho||'" data-evento="blur" style="text-align: '||ws_dado.ds_alinhamento||';" type="text" placeholder="'||ws_dado.nm_rotulo||'" disabled value="'||ws_html_v||'"/>');
                        else
						    case ws_dado.tipo_input

							    when 'textarea' then

									htp.p('<textarea'||ws_read||'id="browserdata-'||ws_count||'" maxlength="'||ws_dado.tamanho||'"  tabindex="'||ws_tab||'" data-evento="blur|change" style="text-align: '||ws_dado.ds_alinhamento||';" placeholder="'||ws_dado.nm_rotulo||'" >'||ws_valor||'</textarea>');

                                when 'sequence' then

									htp.p('<input disabled id="browserdata-'||ws_count||'" tabindex="'||ws_tab||'" style="text-align: '||ws_dado.ds_alinhamento||';" type="text" placeholder="'||ws_dado.nm_rotulo||'" data-dados="'||ws_html_d||'" value="'||REPLACE(ws_html_v, '"', '')||'"/>');
								

								when 'data' then

									htp.p('<input'||ws_read||'id="browserdata-'||ws_count||'" maxlength="'||ws_dado.tamanho||'" onkeydown="if(event.shiftKey === true && (event.keyCode == 190 || event.keyCode == 188)){ return false; event.preventDefault(); }" oninput=" this.value = VMasker.toPattern(this.value, ''99/99/9999'');"  tabindex="'||ws_tab||'" data-evento="blur" style="text-align: '||ws_dado.ds_alinhamento||';" type="text" placeholder="'||ws_dado.nm_rotulo||'" value="'||ws_html_v||'"/>');

                                when 'datatime' then

									htp.p('<input'||ws_read||'id="browserdata-'||ws_count||'" maxlength="'||ws_dado.tamanho||'" onkeydown="if(event.shiftKey === true && (event.keyCode == 190 || event.keyCode == 188)){ return false; event.preventDefault(); }"  oninput=" this.value = VMasker.toPattern(this.value, ''99/99/9999 99:99'');" tabindex="'||ws_tab||'" data-evento="blur" style="text-align: '||ws_dado.ds_alinhamento||';" type="text" placeholder="'||ws_dado.nm_rotulo||'" value="'||ws_html_v||'"/>');

                                when 'ligacao' then
                                    
									if trim(ws_read) = 'disabled' then
                                        htp.p('<span id="browserdata-'||ws_count||'" style="text-overflow: ellipsis; overflow: hidden; background: url(dwu.fcl.download?arquivo=seta.png) no-repeat scroll 98% 8px #FFF; max-width: none; width: 245px; flex: 1 0 calc(60% - 40px);" class="fakeoption readonly" title="" >'||fun.cdesc(ws_valor, ws_dado.cd_ligacao)||'</span>');
                                    else
                                        htp.p('<span id="browserdata-'||ws_count||'" style="text-overflow: ellipsis; overflow: hidden; background: url(dwu.fcl.download?arquivo=seta.png) no-repeat scroll 98% 8px #FFF; max-width: none; width: 245px; flex: 1 0 calc(60% - 40px);" class="fakeoption" title="" onclick="fakeOption(''browserdata-'||ws_count||''', ''Lista de valores'', ''valoresbrowser'', '''||ws_dado.cd_ligacao||''');">'||fun.cdesc(ws_valor, ws_dado.cd_ligacao)||'</span>');
								    end if;

								when 'ligacaoc' then
                                    
									if trim(ws_read) = 'disabled' then
                                        htp.p('<span id="browserdata-'||ws_count||'" style="text-overflow: ellipsis; overflow: hidden; background: url(dwu.fcl.download?arquivo=seta.png) no-repeat scroll 98% 8px #FFF; max-width: none; width: 245px; flex: 1 0 calc(60% - 40px);" class="fakeoption readonly" title="" >'||ws_valor||' - '||fun.cdesc(ws_valor, ws_dado.cd_ligacao)||'</span>');
                                    else
                                        htp.p('<span id="browserdata-'||ws_count||'" style="text-overflow: ellipsis; overflow: hidden; background: url(dwu.fcl.download?arquivo=seta.png) no-repeat scroll 98% 8px #FFF; max-width: none; width: 245px; flex: 1 0 calc(60% - 40px);" class="fakeoption" title="" onclick="fakeOption(''browserdata-'||ws_count||''', ''Lista de valores'', ''valoresbrowser'', '''||ws_dado.cd_ligacao||''');">'||ws_valor||' - '||fun.cdesc(ws_valor, ws_dado.cd_ligacao)||'</span>');
								    end if;
									
								when 'listboxp' then
								    
									htp.p('<select'||ws_read||'id="browserdata-'||ws_count||'" data-evento="change" style="text-align: '||ws_dado.ds_alinhamento||';">');
									    --cd_ligacao
                                        ws_counter := 0;
                                        htp.p('<option value="" hidden/>---</option>');
										for i in(select cd_coluna, cd_conteudo from table(fun.vpipe_par(replace(ws_dado.formula, '$opc|', '')))) loop
                                            if i.cd_coluna = nvl(ws_valor, ws_dado.st_default) then
                                                htp.p('<option value="'||i.cd_coluna||'" selected/>'||i.cd_conteudo||'</option>');
                                            else
                                                htp.p('<option value="'||i.cd_coluna||'" />'||i.cd_conteudo||'</option>');
                                            end if;
                                        end loop;
									 htp.p('</select>');
									 
                                when 'listboxt' then
								    
									htp.p('<select'||ws_read||'id="browserdata-'||ws_count||'" data-evento="change" style="text-align: '||ws_dado.ds_alinhamento||';">');
									    --cd_ligacao
										ws_sql := 'select distinct '||ws_dado.cd_coluna||' from '||prm_tabela||' order by 1';

										ws_cursor := dbms_sql.open_cursor;

										dbms_sql.parse(ws_cursor, ws_sql, DBMS_SQL.NATIVE);
										dbms_sql.define_column(ws_cursor, 1, ws_lista, 200);

										ws_linhas := dbms_sql.execute(ws_cursor);

										loop
											ws_linhas := dbms_sql.fetch_rows(ws_cursor);
											if  ws_linhas <> 1 then 
											    exit; 
											end if;
											dbms_sql.column_value(ws_cursor, 1, ws_lista);

	                                        if ws_valor = ws_lista then
											    htp.p('<option value="'||ws_lista||'" selected>'||ws_lista||'</option>');
											else
											    htp.p('<option value="'||ws_lista||'">'||ws_lista||'</option>');
											end if;
										 end loop;

										 dbms_sql.close_cursor(ws_cursor);
									htp.p('</select>');
									
								else
									begin    
                                        if length(ws_dado.nm_mascara) > 0 then
										    
											if ws_dado.tipo_input = 'number' then
                                                ws_mascara := 'oninput="var precisao = '''||replace(replace(ws_dado.nm_mascara, 'G', '.'), 'D', ',')||'''; if(precisao.split('','')[1]){ precisao = precisao.split('','')[1].length } else { precisao = 0; } VMasker(this).maskMoney({ precision: parseInt(precisao), separator: '','', delimiter: ''.'' });"';
	                                        else
                                                ws_mascara := 'oninput=" this.value = VMasker.toPattern(this.value, '''||ws_dado.nm_mascara||''')"';
                                            end if;
											
                                            if fun.isnumber(trim(ws_valor)) then
										        ws_html_d := trim(ws_valor);
												ws_html_v := trim(to_char(trim(ws_valor), ws_dado.nm_mascara, 'NLS_NUMERIC_CHARACTERS = '||CHR(39)||fun.ret_var('POINT')||CHR(39)));
											else
												ws_html_d := trim(ws_valor);
												ws_html_v := trim(to_char(trim(ws_valor), ws_dado.nm_mascara));
	                                        end if;
											
	                                    else
										    ws_mascara := '';
											ws_html_d := '';
											ws_html_v := trim(ws_valor);
										end if;
                                    exception when others then
					                    ws_html_d := '';
										ws_html_v := trim(ws_valor);
									end;
									
									select tamanho into ws_tamanho from data_coluna where CD_MICRO_DATA = trim(prm_obj) and CD_COLUNA = ws_dado.cd_coluna;

									if(ws_dado.tamanho > ws_tamanho) then
										ws_tamanho := ws_dado.tamanho;
									else
										ws_tamanho := ws_tamanho;

									end if;
									
									htp.p('<input onKeypress="return input(event, '''||ws_dado.tipo_input||''')" '||ws_mascara||''||ws_read||'maxlength="'||ws_tamanho||'" id="browserdata-'||ws_count||'" tabindex="'||ws_tab||'" data-evento="blur" style="text-align: '||ws_dado.ds_alinhamento||';" type="text" placeholder="'||ws_dado.nm_rotulo||'" data-dados="'||ws_html_d||'" value="'||REPLACE(ws_html_v, '"', '')||'"/>');
									
							end case;
						end if;

					exception when others then
                        htp.p(sqlerrm);
					end;

					htp.p('</li>');

				end loop;
			close crs_dados;

		htp.p('</ul>');

		exception
		    when ws_notfound then
				htp.p('<div style="color: #CC0000;">'||substr(prm_linhas(1), 11, length(prm_linhas(1)))||fun.lang('ERRO DE ESTRUTURA')||'</div>');
				INSERT INTO LOG_EVENTOS VALUES (SYSDATE, prm_linhas(1),ws_usuario,prm_obj,'ERRORBROWSER','01');
			when others then
	            INSERT INTO LOG_EVENTOS VALUES (SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK||' -- '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,ws_usuario,'','ERRORBROWSER','01');
	end browserEdit;

	procedure browserExclude ( prm_chave varchar2 default null,
                               prm_campo varchar2 default null,
	                           prm_visao varchar2 default null )  as

		ws_sql     varchar2(4000);
        ws_count   number;
        ws_countc  number;
        ws_where   varchar2(2000);
        ws_linhas  number;
        ws_cursor  integer;
        ws_tipo    varchar2(200);
        ws_tabela  varchar2(200);
        ws_coluna  varchar2(200);
		ws_usuario varchar2(80);

	begin

	    ws_usuario := gbl.getUsuario;

		begin

            ws_count := 0;
            for i in(select column_value from table(fun.vpipe(prm_campo))) loop
                ws_count := ws_count+1;
                ws_where := ws_where||' '||i.column_value||' = '||':b'||trim(to_char(ws_count, '900'))||' and ';
            end loop;

			SELECT ' DELETE FROM '||MICRO_DATA.NM_TABELA||' WHERE '||substr(ws_where, 1, length(ws_where)-4)
            into ws_sql
			FROM MICRO_DATA
			WHERE MICRO_DATA.NM_MICRO_DATA = prm_visao;
			
			SELECT nm_tabela into ws_tabela
			FROM MICRO_DATA
			WHERE MICRO_DATA.NM_MICRO_DATA = prm_visao;

            ws_cursor := dbms_sql.open_cursor;
            dbms_sql.parse(ws_cursor, ws_sql, DBMS_SQL.NATIVE);

            ws_countc := 0;
            for a in(select column_value from table(fun.vpipe(prm_chave))) loop
                ws_countc := ws_countc+1;
                
                select valor into ws_coluna from (select column_value as valor, rownum as linha from table(fun.vpipe(prm_campo))) where linha = ws_countc;
                
                select trim(data_type) into ws_tipo from all_tab_columns where table_name = upper(trim(ws_tabela)) and column_name = ws_coluna;
                
                begin
	                if ws_tipo = 'DATE' then
	                    DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(ws_countc, '900')), to_date(trim(a.column_value), 'DD/MM/YYYY HH24:MI', 'NLS_DATE_LANGUAGE=ENGLISH'));
	                else
	                    DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(ws_countc, '900')), trim(a.column_value));
	                end if;
                exception when others then
	                begin
	                    DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(ws_countc, '900')), to_date(trim(a.column_value), 'DD/MM/YYYY', 'NLS_DATE_LANGUAGE=ENGLISH'));
	                exception when others then
		                DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(ws_countc, '900')), trim(a.column_value));
	                end;
	            end;

            end loop;
           
            ws_linhas := dbms_sql.execute(ws_cursor);
            dbms_sql.close_cursor(ws_cursor);

            htp.p('OK');
            
            insert into bi_log_sistema values(sysdate, 'Registro excluido chave #'||prm_chave||' com campo #'||prm_campo, ws_usuario, 'EVENTO');
            commit;
		exception when others then
            htp.p('ERROR: '||sqlerrm);
		    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' -- '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BRO', ws_usuario, 'ERRO');
            commit;
		end;
  
	end browserExclude;
	

	procedure browserMask (  prm_valor  varchar2 default null,
	                         prm_coluna varchar2 default null,
							 prm_visao  varchar2 default null,
							 prm_tipo   varchar2 default null ) as

	    ws_campo varchar2(200);
	begin

	    if prm_tipo = 'check' then
			select nvl(tamanho, 'N/A') into ws_campo from data_coluna where cd_micro_data = prm_visao and cd_coluna = prm_coluna and rownum = 1;

			begin
				if ws_campo <> 'N/A' then
					if instr(ws_campo, 'MAX') <> 0 then
						if to_number(replace(ws_campo, 'MAX', '')) > length(prm_valor) then
							htp.p('ok');
						else
							htp.p('error');
						end if;
					elsif instr(ws_campo, 'MIN')  <> 0 then
						if to_number(replace(ws_campo, 'MIN', '')) < length(prm_valor) then
							htp.p('ok');
						else
							htp.p('error');
						end if;
					else
						if to_number(ws_campo) = length(prm_valor) then
							htp.p('ok');
						else
							htp.p('error');
						end if;
					end if;
				end if;
			exception when others then
			    htp.p('ok');
			end;
		else
		    select nm_mascara into ws_campo from data_coluna where cd_micro_data = prm_visao and cd_coluna = prm_coluna and rownum = 1;

		    htp.p(to_char(to_number(trim(prm_valor)), ws_campo,'NLS_NUMERIC_CHARACTERS = '||fun.ret_var('POINT')));
		end if;

	end browserMask;

	procedure browserEditLine ( prm_tabela        varchar2 default null,
								prm_chave         varchar2 default null,
								prm_campo         varchar2 default null,
								prm_nome          IN owa_util.vc_arr,
								prm_conteudo      IN owa_util.vc_arr,
								prm_ant           IN owa_util.vc_arr,
                                prm_tipo          in owa_util.vc_arr,
                                prm_obj           varchar2 default null ) as


		ws_status   varchar2(4000);
	    ws_erro     exception;
		ws_admin    varchar2(10);
		ws_usuario  varchar2(80);

	begin
	
	    ws_admin   := gbl.getNivel;
		ws_usuario := gbl.getUsuario;

		BRO.PUT_LINHA(prm_tabela, prm_chave, prm_campo, prm_nome, prm_conteudo, prm_ant, prm_tipo, ws_status, prm_obj);

		if ws_status <> 'OK' then
		    if ws_status <> 'NOCHANGE' then
			    raise ws_erro;
			else
			    htp.p('#alert '||fun.lang('Sem altera&ccedil;&otilde;es')||'!');
			end if;
		end if;
		

	exception
	    when ws_erro then
		    if ws_admin = 'A' then
			    htp.p('#alert '||ws_status);
			else
                insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' -- '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BRO', ws_usuario, 'ERRO');
                commit;
			    htp.p('#alert '||fun.lang('Ocorreu um erro, caso persista, contate o administrador')||'!');
			end if;
		when others then
	        if ws_admin = 'A' then
			    htp.p('#alert Erro'||sqlerrm);
			else
                insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' -- '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BRO', ws_usuario, 'ERRO');
                commit;
			    htp.p('#alert '||fun.lang('Ocorreu um erro, caso persista, contate o administrador')||'!');
			end if;
	end browserEditLine;
	

	procedure browserNewLine (  prm_tabela        varchar2 default null,
								prm_chave         varchar2 default null,
								prm_coluna        varchar2 default null,
								prm_nome          IN owa_util.vc_arr,
								prm_conteudo      IN owa_util.vc_arr,
                                prm_tipo          in owa_util.vc_arr,
                                prm_ident         varchar2 default null,
                                prm_sequence      varchar2 default 'false',
                                prm_obj           varchar2 default null ) as

		ws_status  varchar2(4000);
		ws_erro    exception;
        ws_count   number;
        ws_pointer number;
        ws_sql     varchar2(4000);
        ws_sql_r   number;
        ws_exist   exception;
        ws_quant   varchar2(10);
		ws_admin   varchar2(10);
		ws_usuario varchar2(80);
	begin

	    ws_admin   := gbl.getNivel;
		ws_usuario := gbl.getUsuario;

        ws_sql := 'select count(*) from '||prm_tabela||' where trim('||replace(prm_coluna, '|', ')||trim(')||') = '''||trim(replace(prm_ident, '|', ''))||'''';
		ws_pointer := dbms_sql.open_cursor;
        dbms_sql.parse(ws_pointer, ws_sql, dbms_sql.native);
        dbms_sql.define_column(ws_pointer, 1, ws_quant, 10);
		ws_sql_r := dbms_sql.execute_and_fetch(ws_pointer);
        dbms_sql.column_value(ws_pointer, 1, ws_quant);
        dbms_sql.close_cursor(ws_pointer);

        if to_number(ws_quant) > 0 and prm_sequence = 'false' then
            raise ws_exist;
        end if;
 
		BRO.NEW_LINHA(prm_tabela, prm_chave, prm_coluna, prm_conteudo, prm_tipo, ws_status, prm_obj);
       
		if ws_status <> 'OK' then
		    if ws_status <> 'NOCHANGE' then
			    raise ws_erro;
			else
			    htp.p('#alert '||fun.lang('Imposs&iacute;vel adicionar')||'!');
			end if;
		else
            insert into bi_log_sistema values(sysdate, 'Linha adicionada no browser #'||prm_tabela, ws_usuario, 'EVENTO');
            commit;
        end if;

	exception
        when ws_exist then
            htp.p('#alert Erro, id j&aacute; existente!');
	    when ws_erro then
		    if ws_admin = 'A' then
			    htp.p('#alert '||ws_status);
			else
			    if instr(ws_status, 'ORA-01400') <> 0 then
                    htp.p('#alert '||fun.lang('N&atilde;o pode enviar campo vazio')||'!');
			    else
			        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BRO', ws_usuario, 'ERRO');
                    commit;
			        htp.p('#alert '||fun.lang('Ocorreu um erro, caso persista, contate o administrador')||'!');
			    end if;
			end if;
		when others then
	        if ws_admin = 'A' then
			    	htp.p('#alert Erro '||ws_sql);
			else
                insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BRO', ws_usuario, 'ERRO');
                commit;
			    htp.p('#alert '||fun.lang('Ocorreu um erro, caso persista, contate o administrador')||'!');
			end if;
	end browserNewLine;

	procedure browserConfig ( prm_microdata varchar2 default null) 
								
	as
	    cursor crs_colunas is
		select cd_micro_data, cd_coluna, nm_rotulo, nm_mascara, t3.nm_tabela,
		cd_ligacao, st_chave, st_branco, st_default, st_alinhamento, 
		st_invisivel, formula, tipo, ds_alinhamento, tipo_input, tamanho, 
		validacao, ordem, permissao, t2.data_type
		from data_coluna t1
		left join micro_data t3 on nm_micro_data = t1.cd_micro_data
		left join all_tab_columns t2 on t2.table_name = t3.nm_tabela and t2.column_name = t1.cd_coluna
		where cd_micro_data = prm_microdata
		order by cd_micro_data, st_chave desc, ordem;

		ws_coluna crs_colunas%rowtype;

		ws_param  varchar2(4000);
		ws_count  number;
		ws_decode varchar2(400);
		ws_caplength number := 0;

	begin

		htp.p('<div id="boxbrowser">');
			htp.p('<table id="browserconfig" class="linha">');
				htp.p('<thead>');
					htp.p('<tr>');
						--htp.p('<th>BROWSER</th>');
						htp.p('<th title="'||fun.lang('COLUNA')||'">'||fun.lang('COLUNA')||'</th>');
						htp.p('<th title="'||fun.lang('R&Oacute;TULO')||'">'||fun.lang('R&Oacute;TULO')||'</th>');
						htp.p('<th title="'||fun.lang('ORDEM')||'">'||fun.lang('ORDEM')||'</th>');
						htp.p('<th title="'||fun.lang('MASCARA')||'">'||fun.lang('MASCARA')||'</th>');
						htp.p('<th title="'||fun.lang('LIGA&Ccedil;&Atilde;O')||'">'||fun.lang('LIGA&Ccedil;&Atilde;O')||'</th>');
						htp.p('<th title="'||fun.lang('CHAVE')||'">'||fun.lang('CHAVE')||'</th>');
						htp.p('<th title="'||fun.lang('OBRIGAT&Oacute;RIO')||'">'||fun.lang('OBRIGAT&Oacute;RIO')||'</th>');
						htp.p('<th title="DEFAULT">DEFAULT</th>');
						htp.p('<th title="'||fun.lang('ALINHAMENTO')||'">'||fun.lang('ALINHAMENTO')||'</th>');
						htp.p('<th title="'||fun.lang('VISIBILIDADE')||'">'||fun.lang('VISIBILIDADE')||'</th>');
						htp.p('<th title="'||fun.lang('FORMULA')||'">'||fun.lang('FORMULA')||'</th>');
						htp.p('<th title="'||fun.lang('TIPO')||'">'||fun.lang('TIPO')||'</th>');
						htp.p('<th title="'||fun.lang('ALINHAMENTO MENU')||'">'||fun.lang('ALINHAMENTO MENU')||'</th>');
						htp.p('<th title="INPUT">INPUT</th>');
						htp.p('<th title="'||fun.lang('TAMANHO')||'">'||fun.lang('TAMANHO')||'</th>');
						htp.p('<th title="'||fun.lang('VALIDA&Ccedil;&Atilde;O')||'">'||fun.lang('VALIDA&Ccedil;&Atilde;O')||'</th>');
						--htp.p('<th title="'||fun.lang('PERMISS&Atilde;O')||'">'||fun.lang('PERMISS&Atilde;O')||'</th>');
						htp.p('<th title="'||fun.lang('PERMISS&Atilde;O')||'">'||fun.lang('PERMISS&Atilde;O')||'</th>');
						htp.p('<th title="'||fun.lang('A&Ccedil;&Otilde;ES')||'"></th>');
					htp.p('</tr>');
				htp.p('</thead>');
				
				ws_count := 0;
				
				htp.p('<tbody>');
					open crs_colunas;
						loop
							fetch crs_colunas into ws_coluna;
							exit when crs_colunas%notfound;

							ws_count := ws_count+1;

							htp.p('<tr>');
								--htp.p('<li><input type="text" readonly value="'||ws_coluna.cd_micro_data||'" /></li>');
								htp.p('<td><input type="text" readonly value="'||ws_coluna.cd_coluna||'" /></li>');
								htp.p('<td><input id="rotulo-'||ws_count||'" type="text" value="'||ws_coluna.nm_rotulo||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');
								htp.p('<td><input id="ordem-'||ws_count||'" type="number" value="'||ws_coluna.ordem||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');
								htp.p('<td><input id="mascara-'||ws_count||'" title="EX: 99/99/9999, 999G999D99, 999.999,99 &#10; $[COD] para o c�digo da liga&ccedil;&atilde;o e $[DESC] para descri&ccedil;&atilde;o da liga&ccedil;&atilde;o" type="text" value="'||ws_coluna.nm_mascara||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');

								--htp.p('<li><input id="ligacao-'||ws_count||'" type="text" value="'||ws_coluna.cd_ligacao||'"/></li>');

								htp.p('<td>');
									htp.p('<a class="script" onclick="this.parentNode.parentNode.lastElementChild.children[0].click();"></a>');
									fcl.fakeoption('ligacao-'||ws_count, ''||ws_coluna.cd_ligacao||'', ''||ws_coluna.cd_ligacao||'', 'lista-taux-fixa', 'N', 'N');
									--htp.p('<span style="text-transform: uppercase;" id="ligacao-'||ws_count||'" title="'||ws_coluna.cd_ligacao||'" class="fakeoption" onclick="fakeOption(''ligacao-'||ws_count||''', '''||ws_coluna.cd_micro_data||''', ''cdesc2'', ''''); document.getElementById(''tipoinput-'||ws_count||''').selectedIndex = 4;">'||ws_coluna.cd_ligacao||'</span>');
									--htp.p('<a class="script" onclick="call(''save_column'', ''prm_visao='||prm_microdata||'&prm_name='||ws_coluna.cd_coluna||'&prm_campo=CD_LIGACAO&prm_valor=''+document.getElementById(''ligacao-'||ws_count||''').title).then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_AL); } else { alerta(''feed-fixo'', TR_ER); } });"></a>');
									--fcl.fakeoption('ligacao-'||ws_count||'', ''||ws_coluna.cd_ligacao||'', ''||ws_coluna.cd_ligacao||'', 'lista-taux', 'N', 'N', '');
								htp.p('</td>');
								
								
								--htp.p('<li><input type="text" readonly value="'||ws_coluna.st_chave||'" /></li>');

								htp.p('<td>');
									htp.p('<select id="chave-'||ws_count||'" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();">');
										if ws_coluna.st_chave = '0' then
											htp.p('<option value="0" selected>'||fun.lang('N&atilde;o')||'</option>');
											htp.p('<option value="1">'||fun.lang('Sim')||'</option>');
										else
											htp.p('<option value="0">'||fun.lang('N&atilde;o')||'</option>');
											htp.p('<option value="1" selected>'||fun.lang('Sim')||'</option>');
										end if;
									htp.p('</select>');
								htp.p('</td>');

								--htp.p('<li><input id="branco-'||ws_count||'" type="text" value="'||ws_coluna.st_branco||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');
								
								htp.p('<td>');
									htp.p('<select id="branco-'||ws_count||'" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();">');
										if nvl(ws_coluna.st_branco, '0') = '0' then
											htp.p('<option value="0" selected>'||fun.lang('N&atilde;o')||'</option>');
											htp.p('<option value="1">'||fun.lang('Sim')||'</option>');
										else
											htp.p('<option value="0">'||fun.lang('N&atilde;o')||'</option>');
											htp.p('<option value="1" selected>'||fun.lang('Sim')||'</option>');
										end if;
									htp.p('</select>');
								htp.p('</td>');
								
								htp.p('<td><input id="default-'||ws_count||'" type="text" value="'||ws_coluna.st_default||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');
								htp.p('<td>');
									htp.p('<select id="alinhamento-'||ws_count||'" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();">');
										htp.p('<option value="center">'||fun.lang('Centro')||'</option>');
										if ws_coluna.st_alinhamento = 'left' then
											htp.p('<option value="left" selected>'||fun.lang('Esquerda')||'</option>');
										else
											htp.p('<option value="left">'||fun.lang('Esquerda')||'</option>');
										end if;
										if ws_coluna.st_alinhamento = 'right' then
											htp.p('<option value="right" selected>'||fun.lang('Direita')||'</option>');
										else
											htp.p('<option value="right">'||fun.lang('Direita')||'</option>');
										end if;
									htp.p('</select>');
								htp.p('</td>');
								htp.p('<td>');
									htp.p('<select id="invisivel-'||ws_count||'" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();">');
										if ws_coluna.st_invisivel = 'N' then
											htp.p('<option value="B">'||fun.lang('Browser')||'</option>');
											htp.p('<option value="E">'||fun.lang('Edi&ccedil;&atilde;o')||'</option>');
											htp.p('<option value="N" selected>'||fun.lang('Browser e Edi&ccedil;&atilde;o')||'</option>');
											htp.p('<option value="S">'||fun.lang('Nenhum')||'</option>');
										elsif ws_coluna.st_invisivel = 'B' then
											htp.p('<option value="B" selected>'||fun.lang('Browser')||'</option>');
											htp.p('<option value="E">'||fun.lang('Edi&ccedil;&atilde;o')||'</option>');
											htp.p('<option value="N">'||fun.lang('Browser e Edi&ccedil;&atilde;o')||'</option>');
											htp.p('<option value="S">'||fun.lang('Nenhum')||'</option>');
										elsif ws_coluna.st_invisivel = 'E' then
											htp.p('<option value="B">'||fun.lang('Browser')||'</option>');
											htp.p('<option value="E" selected>'||fun.lang('Edi&ccedil;&atilde;o')||'</option>');
											htp.p('<option value="N">'||fun.lang('Browser e Edi&ccedil;&atilde;o')||'</option>');
											htp.p('<option value="S">'||fun.lang('Nenhum')||'</option>');
										else
											htp.p('<option value="B">'||fun.lang('Browser')||'</option>');
											htp.p('<option value="E">'||fun.lang('Edi&ccedil;&atilde;o')||'</option>');
											htp.p('<option value="N">'||fun.lang('Browser e Edi&ccedil;&atilde;o')||'</option>');
											htp.p('<option value="S" selected>'||fun.lang('Nenhum')||'</option>');
										end if;
									htp.p('</select>');
								htp.p('</td>');
								htp.p('<td><textarea id="formula-'||ws_count||'" value="'||ws_coluna.formula||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();">'||ws_coluna.formula||'</textarea></li>');
								
								htp.p('<td><input id="tipo-'||ws_count||'" type="text" value="'||ws_coluna.tipo||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');
								htp.p('<td>');
									htp.p('<select id="alignds-'||ws_count||'" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();">');
										htp.p('<option value="center">'||fun.lang('Centro')||'</option>');
										if ws_coluna.ds_alinhamento = 'left' then
											htp.p('<option value="left" selected>'||fun.lang('Esquerda')||'</option>');
										else
											htp.p('<option value="left">'||fun.lang('Esquerda')||'</option>');
										end if;
										if ws_coluna.ds_alinhamento = 'right' then
											htp.p('<option value="right" selected>'||fun.lang('Direita')||'</option>');
										else
											htp.p('<option value="right">'||fun.lang('Direita')||'</option>');
										end if;
									htp.p('</select>');
								htp.p('</td>');
								
								--data_type DATE, NUMBER, VARCHAR2, CHAR, LONG
								
								select decode(ws_coluna.tipo_input, 'text', 'TEXTO', 'textarea', 'TEXTO GRANDE', 'DATE', 'DATA', 'number', 'N&Uacute;MERO', 'ligacao', 'LIGA&Ccedil;&Atilde;O', 'listboxp', 'LISTA PR&Eacute;-DEFINIDA', 'listboxt', 'LISTA DA TABELA', 'sequence', 'SEQUENCIA', 'link', 'LINK', ws_coluna.tipo_input) into ws_decode from dual;
								
								--procedure fakeoption (prm_id, prm_placeholder, prm_valor, prm_opcao, prm_editable, prm_multi, prm_visao, prm_fixed, prm_adicional, prm_desc, prm_reverse)
								
								htp.p('<td>');
									htp.p('<a class="script" onclick="this.parentNode.parentNode.lastElementChild.children[0].click();"></a>');
									fcl.fakeoption('tipoinput-'||ws_count, ws_decode, ws_coluna.tipo_input, 'lista-input-browser', 'N', 'N', '', '', ws_coluna.data_type, ws_decode);
								htp.p('</td>');
								
								/*htp.p('<td><select id="tipoinput-'||ws_count||'" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();" title="'||ws_coluna.data_type||'">');
									
									
									if trim(ws_coluna.data_type) = 'DATE' then
									
										if ws_coluna.tipo_input = 'data' then
											htp.p('<option value="data" selected>'||fun.lang('Data')||'</option>');
										else
											htp.p('<option value="data">'||fun.lang('Data')||'</option>');
										end if;
										
										if ws_coluna.tipo_input = 'datatime' then
											htp.p('<option value="datatime" selected>'||fun.lang('Data e hora')||'</option>');
										else
											htp.p('<option value="datatime">'||fun.lang('Data e hora')||'</option>');
										end if;
									
									else
									
										htp.p('<option value="text">'||fun.lang('Texto')||'</option>');
									
										if ws_coluna.tipo_input = 'textarea' then
											htp.p('<option value="textarea" selected>'||fun.lang('Texto grande')||'</option>');
										else
											htp.p('<option value="textarea">'||fun.lang('Texto grande')||'</option>');
										end if;
										
										if ws_coluna.tipo_input = 'number' then
											htp.p('<option value="number" selected>'||fun.lang('N�mero')||'</option>');
										else
											htp.p('<option value="number">'||fun.lang('N�mero')||'</option>');
										end if;
										
										if ws_coluna.tipo_input = 'ligacao' then
											htp.p('<option value="ligacao" selected>'||fun.lang('Liga&ccedil;&atilde;o')||'</option>');
										else
											htp.p('<option value="ligacao">'||fun.lang('Liga&ccedil;&atilde;o')||'</option>');
										end if;
										
										if ws_coluna.tipo_input = 'listboxp' then
											htp.p('<option value="listboxp" selected>'||fun.lang('Listbox pr&eacute;-definida')||'</option>');
										else
											htp.p('<option value="listboxp">'||fun.lang('Listbox pr&eacute;-definida')||'</option>');
										end if;
										
										if ws_coluna.tipo_input = 'listboxt' then
											htp.p('<option value="listboxt" selected>'||fun.lang('Listbox da tabela')||'</option>');
										else
											htp.p('<option value="listboxt">'||fun.lang('Listbox da tabela')||'</option>');
										end if;
										
										if ws_coluna.tipo_input = 'sequence' then
											htp.p('<option value="sequence" selected>'||fun.lang('Sequencia')||'</option>');
										else
											htp.p('<option value="sequence">'||fun.lang('Sequencia')||'</option>');
										end if;
										
										if ws_coluna.tipo_input = 'link' then
											htp.p('<option value="link" selected>'||fun.lang('Link')||'</option>');
										else
											htp.p('<option value="link">'||fun.lang('Link')||'</option>');
										end if;
										
									end if;	
										
								htp.p('</select></td>');*/
								BEGIN
									SELECT DATA_LENGTH INTO ws_caplength FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = ws_coluna.nm_tabela and COLUMN_NAME = TRIM(ws_coluna.cd_coluna);
								exception when others then
									htp.p(sqlerrm);
								end;

								htp.p('<td><input id="tamanho-'||ws_count||'" type="number" max="'||ws_caplength||'" value="'||ws_coluna.tamanho||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');
								htp.p('<td><input id="validacao-'||ws_count||'" type="text" value="'||ws_coluna.validacao||'" onblur="this.parentNode.parentNode.lastElementChild.children[0].click();"/></li>');
								
								htp.p('<td>');
									/*htp.p('<select id="permissao-'||ws_count||'" onchange="this.parentNode.parentNode.lastElementChild.children[0].click();">');
										if ws_coluna.permissao = 'W' then
											htp.p('<option value="W" selected>'||fun.lang('Leitura e escrita')||'</option>');
											htp.p('<option value="R">'||fun.lang('Somente leitura')||'</option>');
										else
											htp.p('<option value="W">'||fun.lang('Leitura e escrita')||'</option>');
											htp.p('<option value="R" selected>'||fun.lang('Somente leitura')||'</option>');
										end if;
									htp.p('</select>');*/
									
									
									--htp.p('<a onclick="fakeOption('''||prm_microdata||''', '''||ws_coluna.cd_coluna||''', ''browser-permissao'', '''');" class="link">PERMISS�ES</a>');
									
									htp.p('<a class="script" onclick="call(''browser_permissao'', ''prm_micro_data='||prm_microdata||'&prm_coluna='||ws_coluna.cd_coluna||'&prm_valor=''+this.nextElementSibling.title, ''BRO'').then(function(resposta){ alerta(''feed-fixo'', TR_AL); });"></a>');
									fcl.fakeoption('permissao-'||ws_count, '', ws_coluna.permissao, 'lista-permissao-browser', 'N', 'S', prm_microdata, 'EDITAR CAMPO', ws_coluna.cd_coluna);
								
								
								htp.p('</td>');

								ws_param := 'prm_microdata='||ws_coluna.cd_micro_data||'&prm_coluna='||ws_coluna.cd_coluna||'&prm_rotulo=''+encodeURIComponent(document.getElementById(''rotulo-'||ws_count||''').value)+''&prm_mascara=''+document.getElementById(''mascara-'||ws_count||''').value+''&prm_ligacao=''+document.getElementById(''ligacao-'||ws_count||''').title+''&prm_chave=''+document.getElementById(''chave-'||ws_count||''').value+''&prm_branco=''+document.getElementById(''branco-'||ws_count||''').value+''&prm_default=''+document.getElementById(''default-'||ws_count||''').value+''&prm_alinhamento=''+document.getElementById(''alinhamento-'||ws_count||''').value+''&prm_invisivel=''+document.getElementById(''invisivel-'||ws_count||''').value+''&prm_formula=''+document.getElementById(''formula-'||ws_count||''').value+''&prm_tipo=''+document.getElementById(''tipo-'||ws_count||''').value+''&prm_alignds=''+document.getElementById(''alignds-'||ws_count||''').value+''&prm_tipoinput=''+document.getElementById(''tipoinput-'||ws_count||''').title+''&prm_tamanho=''+document.getElementById(''tamanho-'||ws_count||''').value+''&prm_validacao=''+document.getElementById(''validacao-'||ws_count||''').value+''&prm_ordem=''+document.getElementById(''ordem-'||ws_count||''').value+''&prm_permissao=';

								htp.p('<td>');
									htp.p('<a class="link inv" onclick="var linha = this.parentNode.parentNode; ajax(''return'', ''browserConfig_alter'', '''||ws_param||'&prm_acao=update'', true, '''', '''', '''', ''bro''); if(respostaAjax != ''FAIL''){ call(''menu'', ''prm_objeto='||prm_microdata||''', ''bro'').then(function(resposta){ document.getElementById(''bro-menu'').innerHTML = resposta; }); alerta(''msg'', TR_AL); } else { alerta(''msg'', TR_ER); }">GRAVAR</a>');
									--fcl.button_lixo('browserConfig_alter', 'prm_microdata|prm_coluna|prm_acao', ws_coluna.cd_micro_data||'|'||ws_coluna.cd_coluna||'|'||'delete');
									htp.p('<a class="remove" title="'||fun.lang('Excluir linha')||'" onclick="if(confirm(TR_OB_EX)){ ajax(''return'', ''browserConfig_alter'', '''||ws_param||'&prm_acao=delete'', false, '''', '''', '''', ''bro''); if(respostaAjax != ''FAIL''){ noerror(this, TR_EX, ''msg''); setTimeout(function(){ carregaPainel(''browser&prm_default='||prm_microdata||'|''+document.getElementById('''||prm_microdata||'_fake'').getAtttribute(''data-visao'')); }, 200); } else { alerta(''msg'', TR_EX); }}">X</a>');
								htp.p('</td>');
							htp.p('</tr>');
						end loop;
					close crs_colunas;
				htp.p('</tbody>');
			htp.p('</div>');
		htp.p('</div>');

	end browserConfig;

	procedure browserConfig_alter ( prm_microdata   varchar2 default null,
	                                prm_coluna      varchar2 default null,
	                                prm_rotulo      varchar2 default null,
	                                prm_mascara     varchar2 default null,
									prm_ligacao     varchar2 default 'SEM',
	                                prm_chave       number default 0,
	                                prm_branco      varchar2 default null,
									prm_default     varchar2 default null,
									prm_alinhamento varchar2 default 'left',
									prm_invisivel   varchar2 default 'N',
									prm_formula     varchar2 default null,
									prm_tipo        varchar2 default 'N',
									prm_alignds     varchar2 default 'left',
									prm_tipoinput   varchar2 default 'text',
									prm_tamanho     varchar2 default null,
									prm_validacao   varchar2 default null,
									prm_ordem       number   default 99,
									prm_permissao   varchar2 default 'R',
									prm_acao        varchar2 default 'update' ) as

		ws_chave     number  := 0;
		ws_count     number;
		ws_fail      exception;
		ws_mascara   varchar2(200) := '';
		ws_tabela    varchar2(200);
		ws_tipo      varchar2(200);
		ws_tipoinput varchar2(200);

	begin

	    case prm_acao
		    when 'update' then
			    begin

	                /*select count(*) into ws_count from data_coluna where cd_micro_data = prm_microdata and st_chave = '1';
					if ws_count = 0 then
						ws_chave := prm_chave;
					end if;*/
					if prm_invisivel = 'S' or prm_invisivel = 'E' then  
						update object_attrib set 
							propriedade = '1'
						where cd_object = prm_microdata and 
						cd_prop = 'DIRECTION';
						COMMIT;	
					end if;
					
					update data_coluna set
					nm_rotulo = fun.converte(prm_rotulo),
					nm_mascara = prm_mascara,
					cd_ligacao = prm_ligacao,
					st_branco = prm_branco,
					st_default = prm_default,
					st_alinhamento = prm_alinhamento,
					st_invisivel = prm_invisivel,
	                st_chave = prm_chave,
					formula = prm_formula,
					tipo = prm_tipo,
					ds_alinhamento = prm_alignds,
					tipo_input = prm_tipoinput,
					tamanho = prm_tamanho,
					validacao = prm_validacao,
					ordem = prm_ordem/*,
					permissao = prm_permissao*/
					where cd_coluna = prm_coluna and
					cd_micro_data = prm_microdata;
	                htp.p('OK');
				exception when others then
				    raise ws_fail;
	
				end;

			when 'insert' then
				begin

	--prm_microdata=CLIENTES_VS prm_coluna=COD_TESTE prm_rotulo=C�DIGO TESTE prm_mascara= prm_ligacao=SEM prm_branco= prm_default=&prm_alinhamento=left&prm_invisivel=N&prm_formula=&prm_tipo=&prm_alignds=left&prm_tipoinput=text&prm_tamanho=0&prm_validacao=&prm_ordem=99&prm_permissao=99&prm_acao=insert

	                if nvl(prm_coluna, 'N/A') = 'N/A' then 
						raise ws_fail;
					end if;
					
					select nm_tabela into ws_tabela from micro_data where nm_micro_data = upper(prm_microdata);
	
	                select data_type into ws_tipo from all_tab_columns where table_name = ws_tabela and column_name = upper(prm_coluna);
	
	                if instr(upper(prm_coluna), 'CD_') > 0 then
					    ws_chave := 1;
					end if;
					
					if ws_tipo = 'DATE' then
					    ws_tipoinput := 'data';
					end if;
					
					if instr(upper(prm_coluna), 'DT_') > 0 and ws_tipo <> 'DATE' then
					    ws_mascara := '99/99/9999';
					end if;
					
					if instr(upper(prm_coluna), 'DS_') > 0 then
					    ws_tipoinput := 'textarea';
					end if;
					
					if ws_tipo = 'NUMBER' then
					    ws_tipoinput := 'number';
					end if;
	 
	
					insert into data_coluna
					(cd_micro_data, cd_coluna, nm_rotulo, nm_mascara, cd_ligacao, st_chave, st_branco, st_default, st_alinhamento, st_invisivel, formula, tipo, ds_alinhamento, tipo_input, tamanho, validacao, ordem, permissao)
					values
					(upper(prm_microdata), upper(prm_coluna), prm_rotulo, ws_mascara, prm_ligacao, ws_chave, prm_branco, prm_default, prm_alinhamento, prm_invisivel, prm_formula, prm_tipo, prm_alignds, ws_tipoinput, prm_tamanho, prm_validacao, prm_ordem, prm_permissao);
	                
                    /*execute immediate 'alter table '||prm_microdata||' add '||upper(prm_coluna)||' varchar2(200)';*/
                    commit;
                    htp.p('OK');
	            exception when others then
				    raise ws_fail;
				end;
			when 'delete' then
				begin
				    delete from data_coluna
					where cd_coluna = prm_coluna and
					cd_micro_data = prm_microdata;
	                htp.p('OK');
				exception when others then
				    raise ws_fail;
				end;
			else
			    htp.p('');
		end case;
	exception
	    when ws_fail then
            rollback;
		    htp.p('FAIL '||DBMS_UTILITY.FORMAT_ERROR_STACK||' -- '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	    when others then
		    htp.p('FAIL');
	end browserConfig_alter;
	
	procedure browser_permissao ( prm_micro_data varchar2 default null,
	                              prm_coluna     varchar2 default null,
	                              prm_valor      varchar2 default null ) as
	
	begin
	
	    update data_coluna
	    set permissao = prm_valor
	    where cd_micro_data = prm_micro_data and
	    cd_coluna = prm_coluna;
	    commit;
	    
	    htp.p('OK');
	exception when others then
	    htp.p('Erro ao alterar a permiss&atilde;o');
	end browser_permissao;

	procedure dt_pagination ( prm_micro_data varchar2 default null,
	                          prm_coluna     varchar2 default null,
	                          prm_objid      varchar2 default null,
							  prm_chave      varchar2 default null,
                              prm_ordem      varchar2 default null,
	                          prm_screen     varchar2 default null,
	                          prm_limite     number   default 10,
							  prm_origem     number   default 0,
							  prm_direcao    varchar2 default '>',
	                          prm_busca      varchar2 default null,
							  prm_condicao   varchar2 default null,
							  prm_acumulado  varchar2 default null ) as
							  
		cursor nc_colunas is 
		SELECT cd_coluna, nm_rotulo, nm_mascara, st_chave, st_default, cd_ligacao, formula, st_alinhamento, ds_alinhamento, tipo_input, column_id, tamanho, data_length, ordem, permissao, st_invisivel, virtual_column
		FROM data_coluna, all_tab_cols
		WHERE cd_micro_data = trim(prm_objid)
		and column_name = cd_coluna and
		trim(table_name) = trim(prm_micro_data)
		order by column_id, st_chave, ordem, permissao;
		
		type nctype is table of nc_colunas%rowtype;

		ws_linha            varchar2(200);
		ws_firstid			char(1);
		ws_counter			number := 1;
		ws_cursor			integer;
		ws_query_montada	dbms_sql.varchar2a;
		ws_lquery			number;
		ws_ncolumns			DBMS_SQL.VARCHAR2_TABLE;
		ws_coluna_ant		DBMS_SQL.VARCHAR2_TABLE;
		ws_sql				long;
		ret_coluna			varchar2(2000);
		ret_coluna_out      varchar2(2000);
		ret_mcol			nctype; --ws_tmcolunas;
		ws_linhas			integer;
		ws_ccoluna			number := 1;
		ws_vazio			boolean := True;
		ws_nodata       	exception;
		ws_semquery			exception;
		ws_queryoc			long;
		ws_sql_pivot		long;
		ws_parseerr			exception;
		ws_query_pivot		long;
		ws_limite_final     number;
		ws_style            varchar2(600) := '';
		ws_class            varchar2(80) := '';
		ws_hint             varchar2(4000) := '';
        ws_chave            varchar2(600);
        ws_blink_linha      varchar2(2000) := 'N/A';
        ws_id               varchar2(4000);
		ws_id_linha         varchar2(4000);
        ws_count_blink      number;
        ws_colunab           varchar2(400);
        ws_contador         number := 0;
	    ws_count_files      number;
	    ws_id_doc           varchar2(32000);
	    ws_count_chave      number;
		ws_valor            varchar2(2000);
		ws_admin            varchar2(10);
		ws_usuario          varchar2(80);
		ws_datad            varchar2(4000);
	begin

	    ws_admin   := nvl(gbl.getNivel, 'N');
		ws_usuario := gbl.getUsuario;

	    open nc_colunas;
		loop
		    fetch nc_colunas bulk collect into ret_mcol limit 200;
		    exit when nc_colunas%NOTFOUND;
		end loop;
		close nc_colunas;

		begin   
            ws_sql := core.DATA_DIRECT(prm_micro_data, prm_coluna, ws_query_montada, ws_lquery, ws_ncolumns, replace(prm_objid, ' full', ''), prm_chave, prm_ordem, prm_screen, prm_limite, prm_origem, prm_direcao, ws_limite_final, prm_condicao, fun.converte(prm_busca), prm_acumulado => prm_acumulado);
        end;

		ws_queryoc := '';
		ws_counter := 0;

		loop
		    ws_counter := ws_counter + 1;
		    if  ws_counter > ws_query_montada.COUNT then
		    	exit;
		    end if;
		    ws_queryoc := ws_queryoc||ws_query_montada(ws_counter);
		end loop;

		if ws_sql = 'Sem Query' then
		   raise ws_semquery;
		end if;

		ws_sql_pivot := ws_query_pivot;

		begin
			ws_cursor := dbms_sql.open_cursor;
			dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );
			ws_counter := 0;

			loop
			    ws_counter := ws_counter + 1;
			    if  ws_counter > ws_ncolumns.COUNT then
			    	exit;
			    end if;
			    dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 2000);
			end loop;

			ws_linhas := dbms_sql.execute(ws_cursor);
			ws_linhas := dbms_sql.fetch_rows(ws_cursor);

			if  ws_linhas = 1 then
			    ws_vazio := False;
		    else
		        dbms_sql.close_cursor(ws_cursor);
		        ws_vazio := True;
	      		raise ws_parseerr;
	        end if;

			dbms_sql.close_cursor(ws_cursor);
		exception
		    when others then
		    	raise ws_parseerr;
		end;

		ws_firstid := 'Y';

		ws_cursor := dbms_sql.open_cursor;

		dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );

		ws_counter := 0;
		loop
		    ws_counter := ws_counter + 1;
		    if  ws_counter > ws_ncolumns.COUNT then
		    	exit;
		    end if;
		    dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 2000);
		end loop;

		ws_linhas := dbms_sql.execute(ws_cursor);
        
		
		ws_id_doc := '';
		ws_linha := 0;
		loop
		    ws_linhas := dbms_sql.fetch_rows(ws_cursor);
		    if  ws_linhas = 1 then
			    ws_vazio := False;
		    else
	            if  ws_vazio = True then
		            dbms_sql.close_cursor(ws_cursor);
	      		    raise ws_nodata;
	        	end if;
	        	exit;
		    end if;
		    ws_counter := 0;

			dbms_sql.column_value(ws_cursor, ws_ncolumns.COUNT, ws_linha);
			dbms_sql.column_value(ws_cursor, 1, ret_coluna);

			ws_id_linha := trim(ret_coluna);
           
			htp.p('<tr id="B'||replace(replace(replace(trim(ret_coluna), ' ', ''), '/', ''), ':', '')||'-'||ws_linha||'" class="'||ws_linha||'">');

			
            ws_id_doc  := '';
			ws_id      := '';
			ws_counter := 0;
			
			loop
				ws_counter := ws_counter + 1;
				if  ws_counter > ws_ncolumns.COUNT then
					exit;
				end if;

				if ws_ncolumns(ws_counter) <> 'DWU_ROWID' and ws_ncolumns(ws_counter) <> 'DWU_ROWNUM' then

					ws_count_chave := 1;
					
					loop
						if ret_mcol(ws_count_chave).cd_coluna = ws_ncolumns(ws_counter) then
							exit;
						end if;
						ws_count_chave := ws_count_chave + 1;
					end loop;

					dbms_sql.column_value(ws_cursor, ws_counter, ws_id_doc);

					if ret_mcol(ws_count_chave).st_chave = '1' then
						ws_id := ws_id||'|'||ws_id_doc;
					end if;
					
				end if;
			end loop;

	        if fun.getprop(prm_objid,'UPLOAD') = 'S' then
	            select count(*) into ws_count_files from tab_documentos where usuario = prm_objid||ws_id;
	            htp.p('<td class="attach" title="'||ws_count_files||' '||fun.lang('arquivos anexos a linha')||'">');
	                htp.p('<div class="attach-div">');
	                    htp.p('<svg class="attach-svg N'||ws_count_files||'" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 351.136 351.136" style="enable-background:new 0 0 351.136 351.136;" xml:space="preserve"> <g> <g id="Clips_2_"> <g> <path d="M324.572,42.699c-35.419-35.419-92.855-35.419-128.273,0L19.931,219.066c-26.575,26.575-26.575,69.635,0,96.211 c21.904,21.904,54.942,25.441,80.769,11.224c2.698-0.136,5.351-1.156,7.415-3.197l176.367-176.367 c17.709-17.709,17.709-46.416,0-64.125s-46.416-17.709-64.125,0L76.052,227.116c-4.422,4.422-4.422,11.61,0,16.031 c4.422,4.422,11.61,4.422,16.031,0L236.388,98.843c8.866-8.866,23.219-8.866,32.063,0c8.866,8.866,8.866,23.219,0,32.063 L100.088,299.268c-17.709,17.709-46.416,17.709-64.125,0s-17.709-46.416,0-64.125L212.33,58.73 c26.575-26.575,69.635-26.575,96.211,0c26.575,26.575,26.575,69.635,0,96.211L148.205,315.277c-4.422,4.422-4.422,11.61,0,16.031 c4.422,4.422,11.61,4.422,16.031,0l160.336-160.336C359.991,135.554,359.991,78.118,324.572,42.699z"/> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');	
	                htp.p('</span>');
	            htp.p('</td>');
	        end if;

			

			ws_count_blink := 0;

            --destaque
		    select count(*) into ws_count_blink from destaque where trim(cd_objeto) = trim(replace(prm_objid, ' full', '')) and trim(tipo_destaque) = 'estrela' and (cd_usuario = ws_usuario or cd_usuario = 'DWU');
			
			if ws_count_blink > 0 then
		        htp.p('<td class="destaqueicon">');
		            htp.p('<svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 19.481 19.481" xmlns:xlink="http://www.w3.org/1999/xlink" enable-background="new 0 0 19.481 19.481"> <g> <path d="m10.201,.758l2.478,5.865 6.344,.545c0.44,0.038 0.619,0.587 0.285,0.876l-4.812,4.169 1.442,6.202c0.1,0.431-0.367,0.77-0.745,0.541l-5.452-3.288-5.452,3.288c-0.379,0.228-0.845-0.111-0.745-0.541l1.442-6.202-4.813-4.17c-0.334-0.289-0.156-0.838 0.285-0.876l6.344-.545 2.478-5.864c0.172-0.408 0.749-0.408 0.921,0z"/> </g> </svg>');
		        htp.p('</td>');
            end if;
			
			ws_counter := 0;

		    loop
				ws_counter := ws_counter + 1;
				if  ws_counter > ws_ncolumns.COUNT then
					exit;
				end if;

	            if ws_ncolumns(ws_counter) <> 'DWU_ROWID' and ws_ncolumns(ws_counter) <> 'DWU_ROWNUM' then
					ws_ccoluna := 1;
					loop
						if ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter) then
							exit;
						end if;
						ws_ccoluna := ws_ccoluna + 1;
					end loop;

					dbms_sql.column_value(ws_cursor, ws_counter, ret_coluna);

					if ws_counter = 1 then
	                    ws_chave := ret_coluna;
	                end if;

					if (ret_mcol(ws_ccoluna).st_invisivel = 'S' or ret_mcol(ws_ccoluna).st_invisivel = 'E') or (ret_mcol(ws_ccoluna).virtual_column = 'YES') then
						ws_class := ' inv';
					else
						ws_class := '';
					end if;

					if length(ws_style) > 0 then
						ws_style := ' style="'||ws_style||'"';
					end if;

					ws_datad := '';
                    
					if ret_mcol(ws_ccoluna).st_chave = '1' then
	                    ws_chave := 'class="chave'||ws_class||'"';
						if nvl(trim(ret_coluna), 'N/A') <> 'N/A' then
							ws_datad := 'data-d="'||trim(ret_coluna)||'"';
						end if;
	                else
	                    ws_chave := 'class="'||trim(ws_class)||'"';
	                end if;

					ws_hint := '';

					begin
					 
					    ret_coluna_out := ret_coluna;
					 
						if ret_mcol(ws_ccoluna).tipo_input = 'data' then
							ret_coluna_out := trim(substr(ret_coluna_out, 1, length(ret_coluna_out)-5));
						end if;
						
						if length(trim(ret_coluna_out)) > 50 then
							ws_colunab := trim(substr(ret_coluna_out, 1, 50))||'...';
						else
							ws_colunab := trim(ret_coluna_out);
						end if;
						
					exception when others then
						ws_colunab := trim(ret_coluna_out);
					end;

                    begin
		                if length(ret_mcol(ws_ccoluna).nm_mascara) > 0 then
		                    if ret_mcol(ws_ccoluna).tipo_input = 'data' and nvl(ret_coluna, 'N/A') <> 'N/A' then 
                                begin
								    htp.p('<td '||ws_style||''||nvl(ws_hint, ' ')||''||ws_chave||' '||ws_datad||'>'||to_char(to_date(ws_colunab, 'DD/MM/YYYY','NLS_DATE_LANGUAGE=ENGLISH'), 'DD/MM/YYYY', 'NLS_DATE_LANGUAGE=PORTUGUESE')||'</td>');
                                exception when others then
								    htp.p('<td '||ws_style||''||nvl(ws_hint, ' ')||''||ws_chave||' '||ws_datad||'>'||to_char(to_date(ws_colunab), 'DD/MM/YYYY')||'</td>');

								end;
							elsif ret_mcol(ws_ccoluna).tipo_input = 'datatime' and nvl(ret_coluna, 'N/A') <> 'N/A' then 
                                
								htp.p('<td '||ws_style||''||nvl(ws_hint, ' ')||''||ws_chave||' '||ws_datad||'>'||ws_colunab||'</td>');
								
							elsif ret_mcol(ws_ccoluna).tipo_input = 'link' then
                                htp.p('<td class="'||ws_class||'" '||ws_style||''||nvl(ws_hint, ' ')||''||ws_chave||' '||ws_datad||' onclick="if(('''||trim(ret_coluna)||''').length > 0){ event.stopPropagation(); window.open(''http://'||replace(replace(ret_coluna, 'http://', ''), 'https://','')||'''); }" class="link">'||trim(ws_colunab)||'</td>');
                            elsif fun.isnumber(trim(ret_coluna)) and ret_mcol(ws_ccoluna).tipo_input = 'number' then
		                        htp.p('<td '||ws_style||''||nvl(ws_hint, ' ')||''||ws_chave||' '||ws_datad||'>'||to_char(ws_colunab, ret_mcol(ws_ccoluna).nm_mascara, 'NLS_NUMERIC_CHARACTERS = '||CHR(39)||fun.ret_var('POINT')||CHR(39))||'</td>');
		                    else
		                    
							    if ret_mcol(ws_ccoluna).tipo_input = 'listboxp' then
							        select cd_conteudo into ws_valor from table(fun.vpipe_par((ret_mcol(ws_ccoluna).formula))) where trim(cd_coluna) = trim(ret_coluna);
							    else
							        if length(trim(ret_mcol(ws_ccoluna).nm_mascara)) > 0 and (instr(ret_mcol(ws_ccoluna).nm_mascara, '$[DESC]') > 0 or instr(ret_mcol(ws_ccoluna).nm_mascara, '$[COD]') > 0) then
								        ws_valor := trim(replace(replace(ret_mcol(ws_ccoluna).nm_mascara, '$[DESC]', fun.cdesc(trim(ret_coluna), ret_mcol(ws_ccoluna).cd_ligacao)), '$[COD]', trim(ret_coluna)));
									else
										if ret_mcol(ws_ccoluna).tipo_input = 'ligacaoc' then
											ws_valor := trim(ret_coluna)||' - '||fun.cdesc(trim(ret_coluna), ret_mcol(ws_ccoluna).cd_ligacao);
										else
											ws_valor := fun.cdesc(trim(ret_coluna), ret_mcol(ws_ccoluna).cd_ligacao);
										end if;
									end if;
							    end if;

                                htp.p('<td '||ws_style||''||nvl(ws_hint, ' ')||''||ws_chave||' '||ws_datad||'>'||ws_valor||'</td>');

							end if;
		                else
                            if ret_mcol(ws_ccoluna).tipo_input = 'data' and nvl(ret_coluna, 'N/A') <> 'N/A' then 
                                htp.p('<td '||ws_style||''||nvl(ws_hint, ' ')||''||ws_chave||' '||ws_datad||'>'||to_char(to_date(ws_colunab), 'DD/MM/YYYY')||'</td>');
							elsif ret_mcol(ws_ccoluna).tipo_input = 'datatime' and nvl(ret_coluna, 'N/A') <> 'N/A' then 
								    htp.p('<td '||ws_style||''||nvl(ws_hint, ' ')||''||ws_chave||' '||ws_datad||'>'||ws_colunab||'</td>');
							elsif ret_mcol(ws_ccoluna).tipo_input = 'link' then
                                htp.p('<td '||ws_style||''||nvl(ws_hint, ' ')||''||ws_chave||' '||ws_datad||' onclick="if(('''||trim(ret_coluna)||''').length > 0){ event.stopPropagation(); window.open(''http://'||replace(replace(ret_coluna, 'http://', ''), 'https://','')||'''); }" class="link">'||trim(ws_colunab)||'</td>');
                            else
							     if ret_mcol(ws_ccoluna).tipo_input = 'listboxp' then
							        select cd_conteudo into ws_valor from table(fun.vpipe_par((ret_mcol(ws_ccoluna).formula))) where trim(cd_coluna) = trim(ret_coluna);
							    elsif ret_mcol(ws_ccoluna).tipo_input = 'ligacaoc' then
								  								    
									ws_valor := trim(ret_coluna)||' - '||fun.cdesc(trim(ret_coluna), ret_mcol(ws_ccoluna).cd_ligacao);

								else
								
									ws_valor := fun.cdesc(trim(ret_coluna), ret_mcol(ws_ccoluna).cd_ligacao);	
										
							    end if;

							    htp.p('<td '||ws_style||''||nvl(ws_hint, ' ')||''||ws_chave||' '||ws_datad||'>'||ws_valor||'</td>');
							end if;
                        end if;
	                exception when others then
					    
	                    htp.p('<td '||ws_style||''||nvl(ws_hint, ' ')||''||ws_chave||' '||ws_datad||'>'||ws_colunab||'</td>');
	                end;
					ws_coluna_ant(ws_counter) := ret_coluna;
				end if;

                if length(fun.check_blink_linha(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, 'B'||ws_id_linha||'-'||ws_linha||'', ret_coluna)) > 7 then
			        ws_blink_linha := ws_blink_linha||fun.check_blink_linha(replace(prm_objid, ' full', ''), ret_mcol(ws_ccoluna).cd_coluna, 'B'||replace(replace(replace(ws_id_linha, ' ', ''), '/', ''), ':', '')||'-'||ws_linha||'', ret_coluna);
			    end if;
			end loop;
		    ws_firstid := 'N';

            if ws_blink_linha <> 'N/A' then 
                htp.p(replace(ws_blink_linha, 'N/A', '')); 
            end if;
	        ws_blink_linha := 'N/A';
            
		    htp.p('</tr>');
		end loop;

		dbms_sql.close_cursor(ws_cursor);
	exception
	    when ws_nodata then
		    insert into bi_log_sistema values(sysdate, 'Sem dados - BRO', ws_usuario, 'ERRO');
            commit;
			fcl.negado(prm_micro_data||' - '||fun.lang('Sem Dados no relat&oacute;rio')||'.');
	    when ws_semquery then
		    htp.p(sqlerrm);
		when ws_parseerr then
		    if ws_admin = 'A' then
				htp.p(ws_queryoc);
			else
				htp.p('SEM DADOS');
			end if;
			insert into bi_log_sistema values(sysdate, ws_queryoc||' - SEM DADOS - BRO', ws_usuario, 'ERRO');
            commit;
        when others then
            if ws_admin = 'A' then
				htp.p(ws_queryoc);
			else
				htp.p('SEM DADOS');
			end if;
			insert into bi_log_sistema values(sysdate, ws_queryoc||' - SEM DADOS - BRO', ws_usuario, 'ERRO');
            commit;
end dt_pagination;

procedure anexo ( prm_chave varchar2 default null ) as

  ws_size    varchar2(200);

begin
  
    fcl.upload(prm_chave);

    htp.p('<ul id="browseredit" class="'||prm_chave||'">');
	    for i in (select name, doc_size, usuario from tab_documentos where usuario = nvl(prm_chave, 'DWU') order by name desc) loop
			htp.p('<li class="fileupload">'); 
				htp.p('<span><a class="link" href="dwu.fcl.download_tab?prm_arquivo='||i.name||'&prm_alternativo='||prm_chave||'" target="_blank">'||i.name||'</a></span>');
				ws_size := to_char(i.doc_size/1024, '9999')||'KB';
				htp.p('<span>'||ws_size||'</span>');
				htp.p('<span style="text-align: right;"><a style="position: relative;" class="remove" title="'||fun.lang('remover imagem')||'" onclick="if(confirm(TR_CE)){ ajax(''fly'', ''remove_image'', ''prm_img='||i.name||'&prm_user='||i.usuario||''', false); noerror(this, '''||fun.lang('Arquivo removido com sucesso')||'!'', ''msg''); }">X</a></span>');
			htp.p('</li>');
        end loop;
	htp.p('</ul>');

end anexo;


PROCEDURE PUT_LINHA  ( prm_tabela           varchar2 default null,
                       prm_chave            varchar2 default null,
	                   prm_campo            varchar2 default null,
	                   prm_nome             owa_util.vc_arr,
	                   prm_conteudo         owa_util.vc_arr,
	                   prm_conteudo_ant     owa_util.vc_arr,
	                   prm_tipo             owa_util.vc_arr,
	                   prm_status           out varchar2,
	                   prm_obj              varchar2 default null
                      ) as

    type generic_cursor is ref cursor;

    crs_saida generic_cursor;
    cursor Crs_Seq (p_colunas varchar2) Is
                        select COLUMN_VALUE as cd_coluna,
                               rownum      as sequencia from 
                        table(fun.vpipe(p_colunas));

    Ws_Seq  			      Crs_Seq%Rowtype;


    ws_cursor           integer;
    ws_busca            varchar2(4000);
    ws_colunas          varchar2(4000);
    ws_update           varchar2(4000);
    ws_ct_col           integer;
    ws_counter          integer;
    ws_linhas           integer;
    ws_virgula          char(1);

    ws_lquery           number;
    ret_coluna          varchar2(4000);

  	ws_col_names        varchar2(4000);
    ws_ref              varchar2(4000);
    ws_notfound         exception;
    ws_status           exception;
    ws_valorer          exception;
    ws_conteudo         varchar2(4000);
    ws_conteudo_ant     varchar2(4000);
	ws_conteudo_sum     varchar2(12000);
    ws_id               varchar2(400);
    ws_ccount           number;
    ws_nochange         exception;
    
    ws_where            varchar2(4000);
    ws_count            number;
    ws_count_dif        number;
	ws_tipo             varchar2(2000);
	ws_usuario          varchar2(80);

BEGIN

    ws_usuario := gbl.getUsuario;

	ws_update := 'UPDATE '||PRM_TABELA||' SET';


	select trim(LISTAGG(COLUMN_NAME,'|') WITHIN GROUP (ORDER BY COLUMN_ID)) into ws_colunas
	from   ALL_TAB_COLUMNS
	where  TABLE_NAME = PRM_TABELA and column_name in (select cd_coluna from data_coluna where cd_micro_data = prm_obj and st_chave = 0);

	select count(*)   into ws_ct_col
	from   table(fun.vpipe(ws_colunas));
	ws_ref := 'XXXX';

	ws_virgula := '';

	 --numero de mudan&ccedil;as
	ws_ccount    := 0;
	ws_count_dif := 0;
	
	
	--define o bind das colunas normais, ignora as que n�o foram alteradas
	Open Crs_Seq (ws_colunas);
	Loop
		Fetch Crs_SEQ Into Ws_SEQ;
			  Exit When Crs_Seq%Notfound;
		begin
		   
			ws_ccount := ws_ccount+1;
			ws_conteudo := prm_conteudo(ws_ccount);
			ws_conteudo_ant := prm_conteudo_ant(ws_ccount);
			
			begin
				ws_conteudo_sum := ws_conteudo_sum||'|'||prm_conteudo(ws_ccount);
			end;

		exception when others then
			raise ws_valorer;      
		end;
			
			begin
				if  nvl(ws_conteudo, 'N/A') <> nvl(ws_conteudo_ant, 'N/A') then
				
				    select tipo_input into ws_tipo from data_coluna where cd_micro_data = prm_obj and cd_coluna = ws_seq.cd_coluna;
					
					--if ws_tipo = 'data' or ws_tipo = 'datatime' then
					--    ws_update := ws_update||ws_virgula||' to_date('||trim(ws_seq.cd_coluna)||', ''DD/MM/YYYY HH24:MI'') = :b'||trim(to_char(ws_ccount,'900'));
					--else
					    ws_update := ws_update||ws_virgula||' '||trim(ws_seq.cd_coluna)||' = :b'||trim(to_char(ws_ccount,'900'));
					--end if;
					ws_virgula := ',';
					ws_count_dif := ws_count_dif+1; 
				end if;
			
			end;

		   if prm_nome(ws_ccount) = prm_chave then
			   ws_id := trim(ws_conteudo);
		   end if;

	End Loop;
	Close Crs_SEQ;
	
	

	if ws_count_dif = 0 then
		raise ws_nochange;
	end if;

	ws_count := ws_ccount;
	--define o bind das chaves
	for i in(select valor as column_value from table(fun.vpipe_order(prm_campo)) where valor not in (select column_name from all_TAB_COLS where trim(table_name) = trim(prm_tabela) and virtual_column = 'YES')) loop
		ws_count := ws_count+1;
		ws_where := ws_where||' '||trim(i.column_value)||' = '||':b'||trim(to_char(ws_count, '900'))||' and ';
	end loop;

	ws_update := ws_update||ws_col_names||' WHERE '||substr(ws_where, 1, length(ws_where)-4);

	ws_cursor := dbms_sql.open_cursor;
	dbms_sql.parse(ws_cursor, ws_update,DBMS_SQL.NATIVE);
	
	ws_ccount := 0;

	--define os valores das colunas para o bind
   Open Crs_Seq (ws_colunas);
		Loop
			Fetch Crs_SEQ Into Ws_SEQ;
			Exit When Crs_Seq%Notfound;
			ws_ccount := ws_ccount+1;
			if nvl(prm_conteudo(ws_ccount), 'N/A') <> nvl(prm_conteudo_ant(ws_ccount), 'N/A') /*and Ws_Seq.cd_coluna <> prm_coluna*/ then
				
				if prm_tipo(ws_ccount) <> 'data' and prm_tipo(ws_ccount) <> 'datatime' then
					ret_coluna := prm_conteudo(ws_ccount);
					DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(ws_ccount,'900')), fun.converte(prm_conteudo(ws_ccount)));
				else
					ret_coluna := to_date(prm_conteudo(ws_ccount), 'DD/MM/YYYY HH24:MI');
					DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(ws_ccount,'900')), to_date(prm_conteudo(ws_ccount), 'DD/MM/YYYY HH24:MI'));
				end if;

				if prm_tipo(ws_ccount) = 'number' then
					ret_coluna := replace(ret_coluna, ',', '');
					ret_coluna := to_number(trim(ret_coluna));
					DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(ws_ccount,'900')), trim(ret_coluna));
				end if;
				
			end if;
		End Loop;
	Close Crs_SEQ;


	for a in(select valor as column_value from table(fun.vpipe_order(prm_chave)) where valor not in (select column_name from all_TAB_COLS where trim(table_name) = trim(prm_tabela) and virtual_column = 'YES')) loop
		ws_ccount := ws_ccount+1;
		DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(ws_ccount, '900')), trim(a.column_value));
	end loop;

	ws_linhas := dbms_sql.execute(ws_cursor);
	dbms_sql.close_cursor(ws_cursor);
	prm_status := 'OK';

    HTP.P(prm_status);

	/*begin
		insert into bi_log_sistema values(sysdate, ws_update||' BINDS: '||ws_conteudo_sum, ws_usuario, 'put_linha');
	exception when others then
        insert into bi_log_sistema values(sysdate, ws_update, ws_usuario, 'put_linha');
	end;*/

exception
    when ws_nochange then
        prm_status := fun.lang('Sem altera&ccedil;&otilde;es');
        htp.p(prm_status);
    when ws_valorer then
        prm_status := DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' linha#'||ws_ccount;
    when ws_status then
        prm_status := DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' '||ws_update;
    when others then
        prm_status := DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' '||ws_update;

END PUT_LINHA;

PROCEDURE GET_LINHA  ( prm_tabela    varchar2 default null,
                       prm_chave     varchar2 default null,
                       prm_coluna    varchar2 default null,
                       prm_conteudo  out DBMS_SQL.VARCHAR2_TABLE,
                       prm_obj       varchar2 default null ) as

    type generic_cursor is ref cursor;

    crs_saida generic_cursor;

    ws_cursor           integer;
    ws_busca            varchar2(4000);
    ws_colunas          varchar2(4000);
    ws_ct_col           integer;
    ws_counter          integer;
    ws_linhas           integer;
    ws_virgula          char(1);

    ws_lquery           number;
    ret_coluna          varchar2(4000);

  	ws_query_montada	varchar2(4000);
    ws_notfound         exception;
    ws_erro             exception;
    ws_count            number;
    ws_countc           number;
    ws_where            varchar2(4000);
    ws_tipo             varchar2(4000);
	ws_test             date;
	type array_tipo is varray(40) of varchar2(120);
    ws_array array_tipo := array_tipo(); 
BEGIN

   
	--calculo do totalizador
    select trim(LISTAGG(COLUMN_NAME,'|') WITHIN GROUP (ORDER BY COLUMN_ID)) into ws_colunas
    from   ALL_TAB_COLUMNS
    where  TABLE_NAME = PRM_TABELA and column_name in (select cd_coluna from data_coluna where cd_micro_data = prm_obj);

    select count(*)  into ws_ct_col
    from   table(fun.vpipe(ws_colunas));
    

    ws_count := 0;
    for i in(select valor as column_value from table(fun.vpipe_order(prm_coluna))) loop
        ws_count := ws_count+1;
        
        select data_type into ws_tipo from all_tab_columns
        where table_name = prm_tabela and column_name = i.column_value;
        
		ws_array.extend;
		ws_array(ws_count) := ws_tipo;

		
        begin
            if ws_tipo  = 'DATE' then
                ws_where := ws_where||' to_date(trim(to_char('||i.column_value||', ''DD/MM/YYYY HH24:MI'')), ''DD/MM/YYYY HH24:MI'') = '||':b'||trim(to_char(ws_count, '900'))||' and ';
            else
                ws_where := ws_where||' trim('||i.column_value||') = '||':b'||trim(to_char(ws_count, '900'))||' and ';
            end if;
        exception when others then
            ws_where := ws_where||' trim('||i.column_value||') = '||':b'||trim(to_char(ws_count, '900'))||' and ';
        end;
		

    end loop;


		for a in(select column_name, data_type 
			from   ALL_TAB_COLUMNS
			where  TABLE_NAME = PRM_TABELA and column_name in (select cd_coluna from data_coluna where cd_micro_data = prm_obj) order by column_id) loop
			
			if a.data_type = 'DATE' then
			    begin
			        ws_query_montada := ws_query_montada||'trim(to_char('||a.column_name||', ''DD/MM/YYYY HH24:MI'')) as '||a.column_name||', ';
				exception when others then
				    ws_query_montada := ws_query_montada||a.column_name||', ';
				end;
			else
			    ws_query_montada := ws_query_montada||a.column_name||', ';
			end if;
		
		
		end loop;
		
		ws_query_montada := 'select '||substr(ws_query_montada, 1, length(ws_query_montada)-2)||' FROM '||PRM_TABELA||' WHERE '||substr(ws_where, 1, length(ws_where)-4);
	
	
    if  trim(ws_colunas) is not null then

    	ws_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(ws_cursor, ws_query_montada,DBMS_SQL.NATIVE);
        
        ws_counter := 0;
        loop
            ws_counter := ws_counter + 1;
            if  ws_counter > ws_ct_col then
                exit;
            end if;
            dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 4000);
			
        end loop;

        ws_countc := 0;
        begin
            for a in(select valor as valor from table(fun.vpipe_order(prm_chave))) loop

                ws_countc := ws_countc+1;
                begin

				    if ws_array(ws_countc) = 'DATE' then
                    
						begin
							--não cai no exception
							DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(ws_countc, '900')), to_date(trim(a.valor), 'DD/MM/YYYY HH24:MI'));
							
						
						exception when others then
							DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(ws_countc, '900')), a.valor);

						end;
						--end if;
					else
                        DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(ws_countc, '900')), a.valor);
					end if;
                exception when others then
                    DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(ws_countc, '900')), trim(a.valor));
                end;
            end loop;

        end;

        ws_linhas := dbms_sql.execute(ws_cursor);

        ws_linhas := dbms_sql.fetch_rows(ws_cursor);
        if  ws_linhas = 0 then
            raise ws_notfound;
        end if;

        ws_counter := 0;
        loop
            ws_counter := ws_counter + 1;
            if  ws_counter > ws_ct_col then
                exit;
            end if;

            dbms_sql.column_value(ws_cursor, ws_counter, ret_coluna);
            prm_conteudo(ws_counter) := ret_coluna;
			
        end loop;

        dbms_sql.close_cursor(ws_cursor);

    end if;

exception
    when ws_erro then
        prm_conteudo(1) := DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    when ws_notfound then
         prm_conteudo(1) := '%ERR%-UPQ-N&atilde;o Encontrado: ['||ws_ct_col||''||prm_chave||']'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||'  '||ws_query_montada;
    when others then
         prm_conteudo(1) := '%ERR%-UPQ-['||ws_ct_col||'-'||prm_chave||']'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||ws_query_montada;

END GET_LINHA;

PROCEDURE NEW_LINHA  (  prm_tabela   varchar2 default null,
                        prm_chave    varchar2 default null,
                        prm_coluna   varchar2 default null,
                        prm_conteudo owa_util.vc_arr,
                        prm_tipo     owa_util.vc_arr,
                        prm_status   out varchar2,
                        prm_obj      varchar2 default null
                        ) as

    type generic_cursor is ref cursor;

    crs_saida generic_cursor;

	Cursor Crs_Seq (p_colunas varchar2) is
        select column_value as cd_coluna,
        rownum as sequencia from 
        table(fun.vpipe(p_colunas)) 
        where column_value not in (select column_name from all_tab_cols where trim(table_name) = trim(prm_tabela) and virtual_column = 'YES');

    Ws_Seq Crs_Seq%Rowtype;


    ws_cursor           integer;
    ws_busca            varchar2(4000);
    ws_colunas          varchar2(4000);
    ws_insert           varchar2(4000);
    ws_ct_col           integer;
    ws_counter          integer;
    ws_linhas           integer;
    ws_virgula          char(1);

    ws_lquery           number;
    ret_coluna          varchar2(2000);

  	ws_col_names        varchar2(4000);
    ws_notfound         exception;

    ws_count_chave      number;
    ws_sequence         number;
    ws_conteudo         varchar2(2000);
    ws_coluna_virtual   varchar2(2000);
	ws_usuario          varchar2(80);
    
BEGIN

    ws_usuario := gbl.getUsuario;

    ws_insert := 'insert into '||PRM_TABELA||' ( ';
	
	select trim(LISTAGG(CD_COLUNA,'|') WITHIN GROUP (ORDER BY CD_COLUNA)) into ws_coluna_virtual from data_coluna where cd_micro_data = prm_obj and 
    cd_coluna not in (select column_name from all_TAB_COLS where trim(table_name) = trim(prm_tabela) and virtual_column = 'YES');

    select trim(LISTAGG(COLUMN_NAME,'|') WITHIN GROUP (ORDER BY COLUMN_ID)), count(COLUMN_NAME) into ws_colunas, ws_ct_col
    from   ALL_TAB_COLUMNS
    where  TABLE_NAME = PRM_TABELA and column_name in (select column_value from table((fun.vpipe(ws_coluna_virtual))));

    select 'insert into '||PRM_TABELA||' ('||LISTAGG(COLUMN_NAME,',')
           WITHIN GROUP (ORDER BY COLUMN_ID)||') values ('
           into ws_insert
    from   ALL_TAB_COLUMNS
    where  TABLE_NAME = PRM_TABELA and column_name in (select column_value from table((fun.vpipe(ws_coluna_virtual))));

    Open Crs_Seq (ws_colunas);
    Loop
        Fetch Crs_SEQ Into Ws_SEQ;
              Exit When Crs_Seq%Notfound;

             ws_insert := ws_insert||ws_virgula||' :b'||trim(to_char(Ws_Seq.Sequencia,'900'));
             ws_virgula := ',';
 
    End Loop;
    Close Crs_SEQ;
    ws_insert := ws_insert||')';

    ws_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(ws_cursor, ws_insert,DBMS_SQL.NATIVE);

    Open Crs_Seq (ws_colunas);
    Loop
        Fetch Crs_SEQ Into Ws_SEQ;
            Exit When Crs_Seq%Notfound;
            ws_conteudo := prm_conteudo(Ws_Seq.Sequencia);
            if prm_tipo(Ws_Seq.Sequencia) = 'data' then
                DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(Ws_Seq.Sequencia,'900')), to_date(ws_conteudo, 'DD/MM/YYYY', 'NLS_DATE_LANGUAGE=ENGLISH'));
            elsif prm_tipo(Ws_Seq.Sequencia) = 'datatime' then
                DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(Ws_Seq.Sequencia,'900')), to_date(ws_conteudo, 'DD/MM/YYYY HH24:MI', 'NLS_DATE_LANGUAGE=ENGLISH'));
			else
                if prm_tipo(Ws_Seq.Sequencia) = 'number' or prm_tipo(Ws_Seq.Sequencia) = 'sequence' then
                    ws_conteudo := replace(ws_conteudo, ',', '');
                    ws_conteudo := to_number(trim(ws_conteudo));
                end if;
                
				if prm_tipo(Ws_Seq.Sequencia) = 'sequence' then
				    ws_conteudo := fun.get_sequence(prm_tabela, Ws_Seq.cd_coluna);
					update bi_sequence
					set sequencia = ws_conteudo
					where nm_tabela = PRM_TABELA and nm_coluna = Ws_Seq.cd_coluna;
					commit;
				end if;


                DBMS_SQL.BIND_VARIABLE(ws_cursor, ':b'||trim(to_char(Ws_Seq.Sequencia,'900')), fun.converte(ws_conteudo));
            end if;

    End Loop;
    Close Crs_SEQ;

    prm_status := 'OK';

    ws_linhas := dbms_sql.execute(ws_cursor);

exception
    when others then
        prm_status := DBMS_UTILITY.FORMAT_ERROR_STACK;
        insert into bi_log_sistema values(sysdate, prm_status||' - BRO', ws_usuario, 'ERRO');
        commit;
END NEW_LINHA;

procedure get_total ( prm_microdata varchar2 default null,
                      prm_objid     varchar2 default null,
                      prm_screen    varchar2 default null,
                      prm_condicao  varchar2 default null,
                      prm_coluna    varchar2 default null,
                      prm_chave     varchar2 default null,
                      prm_ordem     varchar2 default '1',
                      prm_busca     varchar2 default null  ) as

    ws_lquery			number;
    ws_limite_final     number;
    ws_total            number;
    ws_calc             number;
    ws_linhas           integer;
    ws_cursor           integer;
    ws_sql              varchar2(4000);
    ws_query_count	    dbms_sql.varchar2a;
    ws_ncolumns			DBMS_SQL.VARCHAR2_TABLE;
	ws_usuario          varchar2(80);
    
    
    begin

	    ws_usuario := gbl.getUsuario;

	    begin
		    ws_sql := core.DATA_DIRECT(prm_microdata, prm_coluna, ws_query_count, ws_lquery, ws_ncolumns, prm_objid, prm_chave, prm_ordem, prm_screen, nvl(fun.getprop(prm_objid, 'LINHAS', 'DEFAULT', ws_usuario), 50), 0, '>', ws_limite_final, prm_condicao, prm_busca, prm_count => true);
	    end;

	    ws_cursor := dbms_sql.open_cursor;
	    dbms_sql.parse( c => ws_cursor, statement => ws_query_count, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );
		dbms_sql.define_column(ws_cursor, 1, ws_total);
	    ws_linhas := dbms_sql.execute(ws_cursor);
		ws_linhas := dbms_sql.fetch_rows(ws_cursor);
	    dbms_sql.column_value(ws_cursor, 1, ws_total);
	    dbms_sql.close_cursor(ws_cursor);

	    ws_calc := ceil(ws_total/nvl(fun.getprop(prm_objid, 'LINHAS', 'DEFAULT', ws_usuario), 50));
	    if ws_calc < 1 then ws_calc := 1; end if;

        htp.p('<h4 id="browser-page" class="'||ws_calc||'" data-total="'||ws_total||'" data-pagina="1" style="position: fixed; bottom: 5px; right: 5px; font-size: 16px; color: #555; font-family: ''montserrat''; background: #EFEFEF; letter-spacing: 1px;">1/'||ws_calc||'</h4>');

exception when others then
    htp.p(sqlerrm);
end get_total;

procedure menu ( prm_objeto varchar2 default null ) as

    ws_count        number;
    ws_ligacao      varchar2(200);
    ws_data_coluna  varchar2(32000);
    ws_chave        varchar2(2000);

begin

    htp.p('<select id="data-coluna">');
		for i in(select cd_coluna, nm_rotulo, tipo_input from data_coluna where cd_micro_data = prm_objeto order by nm_rotulo asc, cd_coluna asc) loop
			if ws_count = 0 then
                ws_ligacao := i.tipo_input;
            end if;
            ws_count := ws_count +1;
            htp.p('<option value="'||i.cd_coluna||'" data-tipo="'||i.tipo_input||'">'||upper(trim(nvl(i.nm_rotulo, i.cd_coluna)))||'</option>');
			ws_data_coluna := ws_data_coluna||'|'||i.cd_coluna;
		end loop;
	htp.p('</select>');
	
	htp.p('<input type="hidden" id="browser-coluna" value="'||ws_data_coluna||'">');
    select trim((LISTAGG(cd_coluna, '|') WITHIN GROUP (order by column_id, ordem, rownum))) into ws_chave from data_coluna left join all_tab_columns on table_name = 'data_coluna' where cd_micro_data = prm_objeto and st_chave = 1; 
	htp.p('<input type="hidden" id="browser-chave" value="'||ws_chave||'">');

end menu;

procedure main_data ( prm_objid        varchar2 default null,
			          prm_coluna       varchar2 default null,
			          prm_microdata    varchar2 default null,
			          prm_screen       varchar2 default 'DEFAULT',
					  prm_condicao     varchar2 default 'semelhante' ) as

	cursor crs_micro_data is
	select upper(nm_tabela) as tabela, ds_micro_visao as descricao
	from MICRO_DATA where nm_micro_data = prm_objid;

	ws_micro_data crs_micro_data%rowtype;


	type ws_tmcolunas is table of DATA_COLUNA%ROWTYPE
	index by pls_integer;

	type generic_cursor is ref cursor;

	crs_saida generic_cursor;

	cursor nc_colunas is 
	SELECT cd_coluna, nm_rotulo, nm_mascara, st_chave, st_default, cd_ligacao, formula, st_alinhamento, ds_alinhamento, tipo_input, column_id, tamanho, data_length, ordem, permissao, st_invisivel, virtual_column
    FROM data_coluna, all_tab_cols
	WHERE cd_micro_data = trim(prm_objid)
    and column_name = cd_coluna and
    trim(table_name) = trim(prm_microdata)
	order by column_id, st_chave, ordem, permissao;

	type nctype is table of nc_colunas%rowtype;


	ret_coluna			varchar2(2000);
	ret_coluna_out      varchar2(2000);
	ret_mcol			nctype;

	ws_ncolumns			DBMS_SQL.VARCHAR2_TABLE;
	ws_coluna_ant		DBMS_SQL.VARCHAR2_TABLE;
	ws_pvcolumns		DBMS_SQL.VARCHAR2_TABLE;
	ws_mfiltro			DBMS_SQL.VARCHAR2_TABLE;
	ws_vcol				DBMS_SQL.VARCHAR2_TABLE;
	ws_vcon				DBMS_SQL.VARCHAR2_TABLE;


	ws_objid			varchar2(40);
	ws_queryoc			clob;
	ws_pipe				char(1);

	ret_colup			long;
	ws_lquery			number;
	ws_counter			number := 1;
	ws_ccoluna			number := 1;
	ws_xcoluna			number := 0;
	ws_bindn			number := 0;
	ws_cspan			number := 0;
	ws_xcount			number := 0;
	ws_ctnull			number := 0;
	ws_ctcol			number := 0;

	ws_texto			long;
	ws_textot			long;
	ws_nm_var			long;
	ws_content_ant		long;
	ws_content			long;
	ws_coluna			long;
	ws_agrupador		long;
	ws_xatalho			long;

	ws_acesso			exception;
	ws_semquery			exception;
	ws_sempermissao		exception;
	ws_pcursor			integer;
	ws_cursor			integer;
	ws_linhas			integer;
	ws_query_montada	dbms_sql.varchar2a;
	ws_query_pivot		long;
	ws_sql				long;
	ws_sql_pivot		long;
	ws_mode				varchar2(30);
	ws_firstid			char(1);

	ws_vazio			boolean := True;
	ws_nodata       	exception;
	ws_invalido			exception;
	ws_close_html		exception;
	ws_mount			exception;
	ws_parseerr			exception;

	ws_step             number;
	ws_stepper          number := 0;
	ws_linha            varchar2(3000);
	ws_limite_final     number;
	ws_query            varchar2(2000);
	ws_order            varchar2(90);
	ws_tpt              varchar2(400);
	ws_count            number;
	ws_style            varchar2(600) := '';
	ws_class            varchar2(80) := '';
	ws_hint             varchar2(4000) := '';
    ws_null             varchar2(1) := null;
    ws_chave            varchar2(400);
    ws_blink_linha      varchar2(4000) := 'N/A';
    ws_id               varchar2(4000);
	ws_id_linha         varchar2(4000);
    ws_count_blink      number;
    ws_contador         number := 0;
    ws_colunab          varchar2(400);
	ws_colunad          date;
    ws_count_files      number;
    ws_id_doc           varchar2(16000);
    ws_count_chave      number;
	ws_valor            varchar2(2000);
	ws_extra            number;
    ws_usuario          varchar2(80);
    ws_admin            varchar2(4);
begin
	
	ws_usuario := gbl.getUsuario;
	ws_admin   := gbl.getNivel;
	
	if not fun.check_user(ws_usuario) or not fun.check_netwall(ws_usuario) or fun.check_sys <> 'OPEN' then
        insert into log_eventos values(sysdate, 'Página Inicial', ws_usuario, 'chk_user', 'no_user', '01');
        raise ws_acesso;
    end if;
	
	insert into log_eventos values(sysdate, prm_objid||'/'||prm_microdata||'/'||prm_screen||'/'||prm_condicao||'/'||prm_coluna, ws_usuario, 'BROWSER', 'ACESSO', '01');

	ws_coluna := prm_coluna;

	open nc_colunas;
	loop
	    fetch nc_colunas bulk collect into ret_mcol limit 400;
	    exit when nc_colunas%NOTFOUND;
	end loop;
	close nc_colunas;

	ws_counter := 0;
	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > ret_mcol.COUNT then
	    	exit;
	    end if;
	end loop;

	ws_sql_pivot := ws_query_pivot;

    ws_objid := prm_objid;
    
    bro.get_total(prm_microdata, prm_objid, prm_screen, prm_condicao, prm_coluna);

    begin
	    ws_sql := core.DATA_DIRECT(prm_microdata, ws_coluna, ws_query_montada, ws_lquery, ws_ncolumns, prm_objid, '', nvl(fun.getprop(prm_objid, 'DIRECTION', 'DEFAULT', ws_usuario), 1), prm_screen, nvl(fun.getprop(prm_objid, 'LINHAS', 'DEFAULT', ws_usuario), 100), 0, '>', ws_limite_final, prm_condicao, prm_count => false);
	exception when others then
        htp.p(ws_query_montada(6));
    end;


	begin
		
		begin
			ws_cursor := dbms_sql.open_cursor;
			dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );
            
	    exception when others then
		     htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	    end;

		ws_counter := 0;

		loop
		    ws_counter := ws_counter + 1;
		    if  ws_counter > ws_ncolumns.COUNT then
		    	exit;
		    end if;
		    dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 2000);
		end loop;

		ws_linhas := dbms_sql.execute(ws_cursor);
		ws_linhas := dbms_sql.fetch_rows(ws_cursor);

		if  ws_linhas = 1 then
		    ws_vazio := False;
	    else
	        dbms_sql.close_cursor(ws_cursor);
	        ws_vazio := True;
      		raise ws_parseerr;
        end if;
		dbms_sql.close_cursor(ws_cursor);
	exception
	    when others then
            insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BRO', ws_usuario, 'ERRO');
            commit;
	end;

	htp.p('<div class="header" id="'||ws_objid||'header" style="background-color: '||fun.getprop(prm_objid, 'FUNDO_VALOR')||'; font-size: '||fun.getprop(prm_objid, 'SIZE', 'DEFAULT', ws_usuario)||'px;"></div>');
	htp.p('<div class="corpo" style=" font-size: '||fun.getprop(prm_objid, 'SIZE', 'DEFAULT', ws_usuario)||'px;" id="'||ws_objid||'dv2">');

	htp.p('<div id="'||ws_objid||'m">');
	
	
	htp.tableOpen( cattributes => ' id="'||ws_objid||'c" ');

	ws_counter   := 0;
	ws_ccoluna   := 0;
    ws_step := 0;
	htp.p('<tbody></tbody>');
	htp.p('<thead onclick="browserOrder(event)">');
        
	begin

	htp.p('<tr>');
        
		if fun.getprop(prm_objid,'UPLOAD') = 'S' then
			htp.prn('<th style="width: 14px;"></th>');
		end if;

		select count(*) into ws_count_blink from destaque where trim(cd_objeto) = trim(prm_objid) and trim(tipo_destaque) = 'estrela' and (cd_usuario = ws_usuario or cd_usuario = 'DWU');
		if ws_count_blink > 0 then
			htp.prn('<th style="width: 14px;"></th>');
		end if;

		loop

			ws_counter   := ws_counter   + 1;

			if  ws_counter > ws_ncolumns.COUNT then
				exit;
			end if;

			if ws_ncolumns(ws_counter) <> 'DWU_ROWID' and ws_ncolumns(ws_counter) <> 'DWU_ROWNUM' then
				ws_ccoluna := 1;

				loop
					begin
					if  ws_ccoluna = ret_mcol.COUNT or ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter) then
						exit;
					end if;
					exception when others then
						exit;
					end;
					ws_ccoluna := ws_ccoluna + 1;
				end loop;

				if (ret_mcol(ws_ccoluna).st_invisivel = 'S' or ret_mcol(ws_ccoluna).st_invisivel = 'E') or (ret_mcol(ws_ccoluna).virtual_column = 'YES') then
					ws_style := 'style="text-align: '||ret_mcol(ws_ccoluna).st_alinhamento||';"';
					ws_class := 'inv';
				else
					ws_style := 'style="text-align: '||ret_mcol(ws_ccoluna).st_alinhamento||';"';
					ws_class := '';
				end if;
				
				if instr(trim(upper(fun.getprop(prm_objid, 'DIRECTION', 'DEFAULT', ws_usuario))), upper(trim(ret_mcol(ws_ccoluna).cd_coluna))) > 0 then
					if instr(trim(upper(fun.getprop(prm_objid, 'DIRECTION', 'DEFAULT', ws_usuario))), 'DESC') > 0 then
						ws_class := ws_class||' selectedbheader desc';
					else
						ws_class := ws_class||' selectedbheader';
					end if;
				end if;

				if ret_mcol(ws_ccoluna).tipo_input = 'data' or ret_mcol(ws_ccoluna).tipo_input = 'datatime' then
					htp.prn('<th class="'||ws_class||'" data-coluna="'||ret_mcol(ws_ccoluna).cd_coluna||'" data-ordem="TO_DATE('||ret_mcol(ws_ccoluna).cd_coluna||', ''DD/MM/YYYY HH24:MI'')" id="B'||ws_ncolumns(ws_counter)||'" '||ws_style||'>');
				else
					htp.prn('<th class="'||ws_class||'" data-coluna="'||ret_mcol(ws_ccoluna).cd_coluna||'" data-ordem="'||ret_mcol(ws_ccoluna).cd_coluna||'" id="B'||ws_ncolumns(ws_counter)||'" '||ws_style||'>');
				end if;
				
					htp.p(nvl(ret_mcol(ws_ccoluna).nm_rotulo, ret_mcol(ws_ccoluna).cd_coluna));

				htp.p('</th>');
				
			end if;
		end loop;
		htp.p('</tr>');

		ws_style := '';

		ws_bindn  := 0;
		loop
			ws_bindn := ws_bindn + 1;
			if  ws_bindn > ws_pvcolumns.COUNT then
			exit;
			end if;

			ws_pcursor   := dbms_sql.open_cursor;

			begin
				dbms_sql.parse(ws_pcursor, ws_sql_pivot, dbms_sql.native);
			exception
				when others then
					raise ws_semquery;
			end;

			ws_counter := 0;
			loop
				ws_counter := ws_counter + 1;
				if  ws_counter > ws_pvcolumns.COUNT then
					exit;
				end if;
			dbms_sql.define_column(ws_pcursor, ws_counter, ret_colup, 2000);
			end loop;

			ws_ccoluna := 1;
			loop
			if  ws_ccoluna = ret_mcol.COUNT or ret_mcol(ws_ccoluna).cd_coluna = ws_pvcolumns(ws_bindn) then
				exit;
			end if;
			ws_ccoluna := ws_ccoluna + 1;
			end loop;

			ws_linhas := dbms_sql.execute(ws_pcursor);

			htp.tableRowOpen( cattributes => '');

			ws_content_ant := '%First%';
			ws_xcount      := 0;
			loop
			ws_linhas := dbms_sql.fetch_rows(ws_pcursor);

			dbms_sql.column_value(ws_pcursor, ws_bindn, ret_coluna);
			if  ws_content_ant = '%First%' then
				ws_content_ant := ret_coluna;
			end if;

			ws_content_ant := ret_coluna;
			ws_xcount      := ws_xcount + 1;
			end loop;

			if (ret_mcol(ws_ccoluna).st_invisivel = 'S' or ret_mcol(ws_ccoluna).st_invisivel = 'B') or (ret_mcol(ws_ccoluna).virtual_column = 'YES') then
				ws_style := 'style="display: none;"';
			else
				ws_style := 'style="padding: 0; text-align: '||ret_mcol(ws_ccoluna).st_alinhamento||';"';
			end if;

			htp.p('<td colspan="1" style="'||ws_style||'"></td>');

			htp.p('</tr>');

			dbms_sql.close_cursor(ws_pcursor);

		end loop;

		ws_style := '';

		htp.p('</thead>');

	exception when others then
	    if ws_admin = 'A' then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
		else
			htp.p('SEM DADOS');
		end if;
	end;

	ws_cursor := dbms_sql.open_cursor;

	begin
		dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );
    exception when others then
	    if ws_admin = 'A' then
			htp.p(ws_query_montada(1));
			htp.p(ws_query_montada(2));
			htp.p(ws_query_montada(3));
			htp.p(ws_query_montada(4));
			htp.p(ws_query_montada(5));
			htp.p(ws_query_montada(6));
		else
			htp.p('SEM DADOS');
		end if;

    end;

	htp.p('<style>');

		ws_counter := 0;
		ws_extra   := 0;

		if fun.getprop(prm_objid,'UPLOAD') = 'S' then
			ws_extra := ws_extra+1;
		end if;

		if ws_count_blink > 0 then
			ws_extra := ws_extra+1;
		end if;

		loop
			ws_counter := ws_counter + 1;
			if  ws_counter > ws_ncolumns.COUNT then
				exit;
			end if;
			dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 2000);

			if ws_counter <= ret_mcol.COUNT then
				htp.p('div#data_list div.corpo table tbody tr td:nth-child('||nvl(ret_mcol(ws_counter).ordem+ws_extra, ws_counter+ws_extra)||') { text-align: '||ret_mcol(ws_counter).st_alinhamento||'; }');
			end if;
		end loop;

	htp.p('</style>');

    htp.p('<tbody id="ajax" onclick="browserEvent(event, '''||prm_objid||''', ''edit'');">');
	ws_firstid := 'Y';

	ws_linhas := dbms_sql.execute(ws_cursor);

	ws_counter := 0;

	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > ws_ncolumns.COUNT then
			exit;
	    end if;

		begin
			ws_ccoluna := 1;
			loop

			if  ws_ccoluna = ret_mcol.COUNT or ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter) then
				exit;
			end if;
			ws_ccoluna := ws_ccoluna + 1;
			end loop;

		exception when others then
		exit;
	end;

	    ws_coluna_ant(ws_counter) := 'First';
	end loop;

	ws_counter := 0;
	loop
	    ws_counter := ws_counter+1;
	    if ws_counter > ws_query_montada.count then
	        exit;
	    end if;
	end loop;

	loop

		ws_linhas := dbms_sql.fetch_rows(ws_cursor);
	    
		if  ws_linhas = 1 then
		    ws_vazio := False;
	    else
            if  ws_vazio = True then
	            dbms_sql.close_cursor(ws_cursor);
      		    raise ws_nodata;
        	end if;
        	exit;
	    end if;

	    ws_ccoluna := 0;
	    ws_ctnull  := 0;
	    ws_ctcol   := 0;

		dbms_sql.column_value(ws_cursor, 1, ret_coluna);

        ws_contador := ws_contador+1;
		
		ws_id_linha := trim(ret_coluna);

		htp.p('<tr id="B'||replace(replace(replace(replace(ret_coluna, chr(34), chr(39)), ' ', ''), '/', ''), ':', '')||'-'||ws_contador||'" class="'||ws_contador||'">');
        
        /*ws_count_chave := 0;
        ws_id_doc := '';
		
		loop
	        
	        ws_count_chave := ws_count_chave+1;
			if ws_count_chave > ws_ncolumns.COUNT then
				exit;
			end if;
			
			dbms_sql.column_value(ws_cursor, ws_count_chave, ws_id);
				
			begin
			    if ret_mcol(ws_count_chave).st_chave = '1' then
				    dbms_sql.column_value(ws_cursor, ws_count_chave, ws_id_doc);
			        ws_id := ws_id||'|'||ws_id_doc;
			    end if;
			exception when others then
			    exit;
			end;
			
	    end loop;*/
		
		ws_id_doc  := '';
		ws_id      := '';
		ws_counter := 0;
		
		loop
			ws_counter := ws_counter + 1;
			if  ws_counter > ws_ncolumns.COUNT then
				exit;
			end if;

            if ws_ncolumns(ws_counter) <> 'DWU_ROWID' and ws_ncolumns(ws_counter) <> 'DWU_ROWNUM' then

				ws_count_chave := 1;
				
				loop
					if ret_mcol(ws_count_chave).cd_coluna = ws_ncolumns(ws_counter) then
						exit;
					end if;
					ws_count_chave := ws_count_chave + 1;
				end loop;

				dbms_sql.column_value(ws_cursor, ws_counter, ws_id_doc);

                if ret_mcol(ws_count_chave).st_chave = '1' then
                    ws_id := ws_id||'|'||ws_id_doc;
                end if;
				
			end if;
		end loop;

		begin
			if fun.getprop(prm_objid,'UPLOAD') = 'S' then
				select count(*) into ws_count_files from tab_documentos where usuario = prm_objid||ws_id;
				htp.p('<td class="attach" title="'||ws_count_files||' '||fun.lang('arquivos anexos a linha')||'">');
					htp.p('<div class="attach-div">');
						htp.p('<svg class="attach-svg N'||ws_count_files||'" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 351.136 351.136" style="enable-background:new 0 0 351.136 351.136;" xml:space="preserve"> <g> <g id="Clips_2_"> <g> <path d="M324.572,42.699c-35.419-35.419-92.855-35.419-128.273,0L19.931,219.066c-26.575,26.575-26.575,69.635,0,96.211 c21.904,21.904,54.942,25.441,80.769,11.224c2.698-0.136,5.351-1.156,7.415-3.197l176.367-176.367 c17.709-17.709,17.709-46.416,0-64.125s-46.416-17.709-64.125,0L76.052,227.116c-4.422,4.422-4.422,11.61,0,16.031 c4.422,4.422,11.61,4.422,16.031,0L236.388,98.843c8.866-8.866,23.219-8.866,32.063,0c8.866,8.866,8.866,23.219,0,32.063 L100.088,299.268c-17.709,17.709-46.416,17.709-64.125,0s-17.709-46.416,0-64.125L212.33,58.73 c26.575-26.575,69.635-26.575,96.211,0c26.575,26.575,26.575,69.635,0,96.211L148.205,315.277c-4.422,4.422-4.422,11.61,0,16.031 c4.422,4.422,11.61,4.422,16.031,0l160.336-160.336C359.991,135.554,359.991,78.118,324.572,42.699z"/> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');	
						/*htp.p('<span class="attach-number" title="'||prm_objid||ws_id_doc||'">'||ws_count_files||'</span>');*/
					htp.p('</span>');
				htp.p('</td>');
			end if;
		exception when others then
			htp.p(sqlerrm);
		end;
		
		select count(*) into ws_count_blink from destaque where cd_objeto = replace(prm_objid, ' full', '') and tipo_destaque = 'estrela' and (cd_usuario = ws_usuario or cd_usuario = 'DWU');
        
		if ws_count_blink > 0 then
	        htp.p('<td class="destaqueicon">');
	            htp.p('<svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 19.481 19.481" xmlns:xlink="http://www.w3.org/1999/xlink" enable-background="new 0 0 19.481 19.481"> <g> <path d="m10.201,.758l2.478,5.865 6.344,.545c0.44,0.038 0.619,0.587 0.285,0.876l-4.812,4.169 1.442,6.202c0.1,0.431-0.367,0.77-0.745,0.541l-5.452-3.288-5.452,3.288c-0.379,0.228-0.845-0.111-0.745-0.541l1.442-6.202-4.813-4.17c-0.334-0.289-0.156-0.838 0.285-0.876l6.344-.545 2.478-5.864c0.172-0.408 0.749-0.408 0.921,0z"/> </g> </svg>');
	        htp.p('</td>');
        end if;

	    ws_counter := 0;
	    loop
			ws_counter := ws_counter + 1;
			if  ws_counter > ws_ncolumns.COUNT then
				exit;
			end if;

            if ws_ncolumns(ws_counter) <> 'DWU_ROWID' and ws_ncolumns(ws_counter) <> 'DWU_ROWNUM' then

				ws_ccoluna := 1;
				loop
					if ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter) then
						exit;
					end if;
					ws_ccoluna := ws_ccoluna + 1;
				end loop;

				dbms_sql.column_value(ws_cursor, ws_counter, ret_coluna);

				 if (ret_mcol(ws_ccoluna).st_invisivel = 'S' or ret_mcol(ws_ccoluna).st_invisivel = 'E') or (ret_mcol(ws_ccoluna).virtual_column = 'YES') then
					ws_class := 'inv';
				else
					ws_class := '';
				end if;
				
                if ret_mcol(ws_ccoluna).st_chave = '1' then
                    ws_chave := 'class="chave '||ws_class||'"';
                else
                    ws_chave := 'class="'||ws_class||'"';
                end if;

				if length(ws_style) > 0 then
					ws_style := ' style="'||ws_style||'"';
				end if;

				ws_hint := '';

                begin
				    /*testar se varchar ou date na tabela*/
	                
					ret_coluna_out := ret_coluna;
					 
					if ret_mcol(ws_ccoluna).tipo_input = 'data' then
						ret_coluna_out := trim(substr(ret_coluna_out, 1, length(ret_coluna_out)-5));
					end if;
					
					if length(trim(ret_coluna)) > 50 then
						ws_colunab := trim(substr(ret_coluna_out, 1, 50));
					else
						ws_colunab := trim(ret_coluna_out);
					end if;
					
                exception when others then
                    ret_coluna := trim(ret_coluna_out);
                end;
                
                begin
	                if length(ret_mcol(ws_ccoluna).nm_mascara) > 0 then
	                    if ret_mcol(ws_ccoluna).tipo_input = 'data' and nvl(ret_coluna, 'N/A') <> 'N/A' then
                            begin
                                htp.p('<td '||ws_style||' '||ws_hint||' '||ws_chave||' data-d="'||replace(trim(ret_coluna), chr(34), '&quot;')||'">'||to_char(to_date(ws_colunab), 'DD/MM/YYYY')||'</td>');
                            exception when others then
                                htp.p('<td '||ws_style||' '||ws_hint||' '||ws_chave||' data-d="'||replace(trim(ret_coluna), chr(34), '&quot;')||'">'||ws_colunab||'</td>');
                            end;
                        elsif ret_mcol(ws_ccoluna).tipo_input = 'link' then
                            htp.p('<td '||ws_style||' '||ws_hint||' '||ws_chave||' data-d="'||trim(ret_coluna)||'" onclick="if(('''||trim(ret_coluna)||''').length > 0){ event.stopPropagation(); window.open(''http://'||replace(replace(ret_coluna, 'http://', ''), 'https://','')||'''); }" class="link">'||ws_colunab||'</td>');
                        elsif fun.isnumber(trim(ret_coluna)) and ret_mcol(ws_ccoluna).tipo_input = 'number' then
	                        htp.p('<td '||ws_style||' '||ws_hint||' '||ws_chave||' data-d="'||trim(ret_coluna)||'">'||to_char(ws_colunab, ret_mcol(ws_ccoluna).nm_mascara, 'NLS_NUMERIC_CHARACTERS = '||CHR(39)||fun.ret_var('POINT')||CHR(39))||'</td>');
                        else
	                        
							if ret_mcol(ws_ccoluna).tipo_input = 'listboxp' then
								select cd_conteudo into ws_valor from table(fun.vpipe_par((ret_mcol(ws_ccoluna).formula))) where trim(cd_coluna) = trim(ret_coluna);
							else
								if length(trim(ret_mcol(ws_ccoluna).nm_mascara)) > 0 and (instr(ret_mcol(ws_ccoluna).nm_mascara, '$[DESC]') > 0 or instr(ret_mcol(ws_ccoluna).nm_mascara, '$[COD]') > 0) then
									ws_valor := trim(replace(replace(ret_mcol(ws_ccoluna).nm_mascara, '$[DESC]', fun.cdesc(trim(ret_coluna), ret_mcol(ws_ccoluna).cd_ligacao)), '$[COD]', trim(ret_coluna)));
								else
								    if ret_mcol(ws_ccoluna).tipo_input = 'ligacaoc' then
									    ws_valor := trim(ret_coluna)||' - '||fun.cdesc(trim(ret_coluna), ret_mcol(ws_ccoluna).cd_ligacao);
									else
                                        ws_valor := fun.cdesc(trim(ret_coluna), ret_mcol(ws_ccoluna).cd_ligacao);
									end if;
								end if;
							end if;
							
							htp.p('<td '||ws_style||' '||ws_hint||' '||ws_chave||' data-d="'||trim(ret_coluna)||'">'||ws_valor||'</td>');
	                    end if;
	                else
                        if ret_mcol(ws_ccoluna).tipo_input = 'data' and nvl(ret_coluna, 'N/A') <> 'N/A' then
	                        begin
							    htp.p('<td '||ws_style||' '||ws_hint||' '||ws_chave||' data-d="'||trim(ret_coluna)||'">'||to_char(to_date(ws_colunab), 'DD/MM/YYYY')||'</td>');
							exception when others then 
                                htp.p('<td '||ws_style||' '||ws_hint||' '||ws_chave||' data-d="'||trim(ret_coluna)||'">'||ws_colunab||'</td>');
                            end;
                        elsif ret_mcol(ws_ccoluna).tipo_input = 'link' then
                            htp.p('<td '||ws_style||' '||ws_hint||' '||ws_chave||'  data-d="'||trim(ret_coluna)||'" onclick="if(('''||trim(ret_coluna)||''').length > 0){ event.stopPropagation(); window.open(''http://'||replace(replace(ret_coluna, 'http://', ''), 'https://','')||'''); }" class="link '||ws_class||'">'||ws_colunab||'</td>');
                        else
						    if ret_mcol(ws_ccoluna).tipo_input = 'listboxp' then
							    select cd_conteudo into ws_valor from table(fun.vpipe_par((ret_mcol(ws_ccoluna).formula))) where trim(cd_coluna) = trim(ret_coluna);
							else
							    if length(trim(ret_mcol(ws_ccoluna).nm_mascara)) > 0 and (instr(ret_mcol(ws_ccoluna).nm_mascara, '$[DESC]') > 0 or instr(ret_mcol(ws_ccoluna).nm_mascara, '$[COD]') > 0) then
									ws_valor := trim(replace(replace(ret_mcol(ws_ccoluna).nm_mascara, '$[DESC]', fun.cdesc(trim(ret_coluna), ret_mcol(ws_ccoluna).cd_ligacao)), '$[COD]', trim(ret_coluna)));
								else
									if ret_mcol(ws_ccoluna).tipo_input = 'ligacaoc' then
									    ws_valor := trim(ret_coluna)||' - '||fun.cdesc(trim(ret_coluna), ret_mcol(ws_ccoluna).cd_ligacao);
									else
                                        ws_valor := fun.cdesc(trim(ret_coluna), ret_mcol(ws_ccoluna).cd_ligacao);
									end if;
								end if;
							end if;
							
							htp.p('<td '||ws_style||' '||ws_hint||' '||ws_chave||' data-d="'||trim(ret_coluna)||'">'||ws_valor||'</td>');

	                    end if;
                    end if;
                exception when others then
					htp.p('<td '||ws_style||' '||ws_hint||' '||ws_chave||' data-f=""  data-d="'||trim(ret_coluna)||'"  data-tipo="'||ret_mcol(ws_ccoluna).tipo_input||'">'||ws_colunab||'</td>');
                end;

				ws_coluna_ant(ws_counter) := ret_coluna;

			end if;

            if length(fun.check_blink_linha(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, 'B'||ws_id_linha||'-'||ws_contador||'', ret_coluna, prm_screen)) > 7 then
		        ws_blink_linha := ws_blink_linha||fun.check_blink_linha(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, 'B'||replace(replace(replace(ws_id_linha, ' ', ''), '/', ''), ':', '')||'-'||ws_contador||'', ret_coluna, prm_screen);
		    end if;

		end loop;
	    ws_firstid := 'N';

		if ws_blink_linha <> 'N/A' then 
            htp.p(replace(ws_blink_linha, 'N/A', ''));
        end if;
	    ws_blink_linha := 'N/A';

	    htp.p('</tr>');
	end loop;
	dbms_sql.close_cursor(ws_cursor);
	htp.p('</tbody>');
	htp.p('</table>');
	htp.p('</div>');

	ws_style   := '';
	ws_textot  := '';
	ws_pipe    := '';
	ws_counter := 0;

	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > ws_ncolumns.COUNT then
		exit;
	    end if;

	    ws_ccoluna := 1;
	    loop
		begin
		    if  ws_ccoluna = ret_mcol.COUNT or ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter) then
		        exit;
		    end if;
		exception when others then
		    exit;
		end;
		ws_ccoluna := ws_ccoluna + 1;
	    end loop;
	end loop;

	htp.p('</div>');

exception
    when ws_mount then
	    fcl.iniciar;
    when ws_close_html then
	    fcl.POSICIONA_OBJETO('newquery','DWU','DEFAULT','DEFAULT');
	when ws_parseerr   then

		if ws_vazio then
		    htp.p(ws_null);
		else
		    htp.p(ws_null);
		end if;

	    commit;

		htp.p('<span style="text-align: center; text-transform: uppercase; font-weight: bold; cursor: move; display: block;">'||fun.lang('Sem Dados')||'</span>');
		
		if ws_admin = 'A' then
			htp.tableOpen( cattributes => ' id="'||ws_objid||'c" style="width: 500px;"');
				htp.tableRowOpen( cattributes => 'style="background: '||fun.getprop(prm_objid, 'FUNDO_CABECALHO')||'; color: '||fun.getprop(prm_objid, 'FONTE_CABECALHO')||';" border="0" id="'||ws_objid||'_tool" ');
					htp.p('<td colspan="'||ws_ncolumns.COUNT||'" align="left"></td>');
				htp.tableRowClose;
				htp.tableRowOpen( cattributes => ' style="background: '||fun.getprop(prm_objid, 'FUNDO_CABECALHO')||'; color: '||fun.getprop(prm_objid, 'FONTE_CABECALHO')||';" border="0" id="'||ws_objid||'_tool" ');
					fcl.TableDataOpen( ccolspan => ws_ncolumns.COUNT, calign => 'LEFT');
						htp.p('<div align="center">' || htf.bold( '<FONT size="7">'));
						ws_counter := 0;
						loop
							ws_counter := ws_counter + 1;
							if  ws_counter > ws_query_montada.COUNT then
								exit;
							end if;
							HTP.P(ws_query_montada(ws_counter));
						end loop;
						htp.p('</font></div>');
					fcl.TableDataClose;
				htp.tableRowClose;
		    htp.tableClose;
		end if;

		htp.p('<div align="center"><img alt="'||fun.lang('alerta')||'" src="'||fun.r_gif('warning','PNG')||'"></div>');

		htp.p('</div>');
	when ws_invalido then
	   commit;
	   fcl.negado(fun.lang('Parametros Invalidos'));
       htp.p('');
	when ws_acesso then
	   fcl.negado(prm_objid);
       htp.p('');
	when ws_semquery then
	    commit;
        insert into bi_log_sistema values(sysdate, 'Sem query - BRO', ws_usuario, 'ERRO');
        commit;
	when ws_nodata  then
        insert into bi_log_sistema values(sysdate, 'Sem dados - BRO', ws_usuario, 'ERRO');
        commit;
	when ws_sempermissao then
	   fcl.negado(prm_objid||' - '||fun.lang('Sem Permiss&atilde;o Para Este Filtro')||'.');
       insert into bi_log_sistema values(sysdate, 'Sem permiss&atilde;o - BRO', ws_usuario, 'ERRO');
       commit;
	when others	then
	   commit;
       insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BRO', ws_usuario, 'ERRO');
       commit;
       if ws_admin = 'A' then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
		else
			htp.p('SEM DADOS');
		end if;
	   htp.p('</div>');
end main_data;

procedure properties ( prm_id varchar2 ) as

	cursor crs_objetos is
	select * from OBJETOS where cd_objeto = prm_id;

	ws_obj crs_objetos%rowtype;

	cursor crs_agrupadores is
	select column_value, (select max(nm_rotulo) from micro_coluna where cd_coluna = column_value) as coluna from table(fun.vpipe((select cs_agrupador from ponto_avaliacao where cd_ponto = prm_id)));

	ws_agrupador crs_agrupadores%rowtype;

	ws_micro_visao   varchar2(80);
	ws_grupo         varchar2(2000);
	ws_micro_count   number;
	ws_count         number;
	ws_tabela        varchar2(40);
	ws_valor         varchar2(800);
	ws_usuario       varchar2(40);
	ws_desc			 varchar2(40);		
	ws_nouser        exception;
begin
    
	ws_usuario := gbl.getUsuario;

	if ws_usuario = 'NOUSER' then
		raise ws_nouser;
	end if;

	open crs_objetos;
	fetch crs_objetos into ws_obj;
	close crs_objetos;

	htp.p('<div class="itens" data-obj="'||prm_id||'" style="width: 346px;" onmouseleave="if(document.getElementById('''||prm_id||''')){ document.getElementById('''||prm_id||''').classList.remove(''destacada''); }" onmouseenter="if(document.getElementById('''||prm_id||''')){ document.getElementById('''||prm_id||''').classList.add(''destacada''); }">');

		htp.p('<h2>'||fun.lang('PROPRIEDADES')||'</h2>');

		htp.p('<ul class="form">');

		select count(*) into ws_micro_count from micro_data where nm_micro_data = ws_micro_visao;

		if ws_micro_count = 1 then
			select nm_tabela into ws_tabela from micro_data where nm_micro_data = ws_micro_visao;
			if length(ws_tabela) > 0 then
				htp.p('<li class="readonly">');
			else
				htp.p('<li style="display: none;">');
			end if;
			    htp.p('<span class="before">'||fun.lang('Tabela')||'</span>');
				htp.p('<span class="after">');
				    htp.p('<input type="text" readonly="true" title="'||ws_tabela||'" value="'||ws_tabela||'" />');
				htp.p('</span>');
			htp.p('</li>');
		end if;

		select count(*) into ws_micro_count from micro_visao where nm_micro_visao = ws_micro_visao;

		if ws_micro_count = 1 then
			select nm_tabela into ws_tabela from micro_visao where nm_micro_visao = ws_micro_visao;
			if length(ws_tabela) > 0 then
				htp.p('<li class="readonly">');
			else
				htp.p('<li style="display: none;">');
			end if;
			    htp.p('<span class="before">'||fun.lang('Tabela')||'</span>');
				htp.p('<span class="after">');
				    htp.p('<input type="text" readonly="true" title="'||ws_tabela||'" value="'||ws_tabela||'" />');
				htp.p('</span>');
			htp.p('</li>');
		end if;
 
        htp.p('<li class="readonly">');
		    htp.p('<span class="before">ID</span>');
			htp.p('<span class="after">');
				htp.p('<input type="text" readonly id="ident" data-default="'||prm_id||'" class="p_cd_objeto" value="'||ws_obj.cd_objeto||'" >');
			htp.p('</span>');
		htp.p('</li>');

		htp.p('<li>');
		    htp.p('<span class="before">COD</span>');
			htp.p('<span class="after">');
			    htp.p('<input id="'||prm_id||'cod" type="text" data-default="'||ws_obj.cod||'" onkeyup="if(this.value != this.getAttribute(''data-default'')){ ajax(''input'', ''check_data'', ''prm_valor=''+this.value+''&prm_tabela=objetos'', true, '''||prm_id||'cod''); }" onblur="if(this.value != this.getAttribute(''data-default'')){ if(!this.classList.contains(''error'')){ update_prop('''||prm_id||''', ''COD'', this.value); this.setAttribute(''data-default'', this.value); this.classList.remove(''ok''); }}"  value="'||ws_obj.cod||'" maxlength="80" >');
			htp.p('</span>');
		htp.p('</li>');

		htp.p('<li>');
			htp.p('<span class="before">'||fun.lang('Nome')||'</span>');
			htp.p('<span class="after">');
			    htp.p('<textarea onkeypress="if(!input(event, ''nobr'')){ event.preventDefault(); }" onblur="update_prop(document.getElementById(''ident'').value, ''nome'', this.value);" title="'||ws_obj.nm_objeto||'" value="'||replace(ws_obj.nm_objeto, '"', '&quot;')||'" size="50" maxlength="80">'||replace(ws_obj.nm_objeto, '"', '&quot;')||'</textarea>');
		    htp.p('</span>');
			htp.p('<a class="fakelang mini" onclick="fakeLang('''||ws_obj.nm_objeto||'_nome'', '''||prm_id||'|NM_OBJETO|''+this.previousElementSibling.children[0].title);">L</a>');
		htp.p('</li>');

		htp.p('<li>');
			
			select t1.cd_grupo, nm_grupo into ws_grupo, ws_desc 
			from objetos t1
			left join grupos_funcao t2 on t2.cd_grupo = t1.cd_grupo
			where cd_objeto = trim(prm_id);
			

			htp.p('<span class="before">'||fun.lang('Grupo')||'</span>');
			htp.p('<span class="after">');
		        htp.p('<a class="script" onclick="update_prop(document.getElementById(''ident'').value, ''grupo'', this.nextElementSibling.title);  document.querySelector(''.itens'').setAttribute(''data-alterado'', ''T'');"></a>');
		        fcl.fakeoption('fake-grupo', fun.lang('Escolha um grupo'), ws_grupo, 'lista-grupos', 'N', 'N', '', prm_desc => ws_grupo||' - '||ws_desc);
			htp.p('</span>');

		htp.p('</li>');

            
			htp.p('<li class="readonly">');
				htp.p('<span class="before">'||fun.lang('TABELA')||'</span>');
			    htp.p('<span class="after">');
				    select nm_tabela into ws_valor from micro_data where nm_micro_data = prm_id;
				    htp.p('<input type="text" readonly="true" value="'||ws_valor||'"/>');
				htp.p('</span>');
			htp.p('</li>');
			
			htp.p('<li>');
				
				htp.p('<span class="before">'||fun.lang('Upload')||'</span>');
				
				htp.p('<span class="after">');
					
					htp.p('<a class="script" onclick="call(''alter_attrib'', ''prm_objeto='||prm_id||'&prm_prop=UPLOAD&prm_value=''+this.nextElementSibling.title+''&prm_usuario=DWU'').then(function(res){ if(res.indexOf(''#alert'') == -1){ alerta(''feed-fixo'', TR_AL); } else { alerta(''feed-fixo'', TR_ER); } });"></a>');
					if fun.getprop(prm_id,'UPLOAD') = 'S' then
						htp.p('<span class="checkbox checked" data-positive="S" data-negative="N" title="'||fun.getprop(prm_id,'UPLOAD')||'"></span>');
					else
						htp.p('<span class="checkbox" data-positive="S" data-negative="N" title="'||fun.getprop(prm_id,'UPLOAD')||'"></span>');
					end if;

				htp.p('</span>');
				
			htp.p('</li>');

			htp.p('<li>');
				
				htp.p('<span class="before">'||fun.lang('Multiplo')||'</span>');
				
				htp.p('<span class="after">');
					
					htp.p('<a class="script" onclick="call(''alter_attrib'', ''prm_objeto='||prm_id||'&prm_prop=MULTI&prm_value=''+this.nextElementSibling.title+''&prm_usuario=DWU'').then(function(res){ if(res.indexOf(''#alert'') == -1){ alerta(''feed-fixo'', TR_AL); } else { alerta(''feed-fixo'', TR_ER); } });"></a>');
					if fun.getprop(prm_id,'MULTI') = 'S' then
						htp.p('<span class="checkbox checked" data-positive="S" data-negative="N" title="'||fun.getprop(prm_id,'MULTI')||'"></span>');
					else
						htp.p('<span class="checkbox" data-positive="S" data-negative="N" title="'||fun.getprop(prm_id,'MULTI')||'"></span>');
					end if;

				htp.p('</span>');
				
			htp.p('</li>');
			
			htp.p('<li>');
				
				htp.p('<span class="before">'||fun.lang('Bloqueio de edi&ccedil;&atilde;o')||'</span>');
				htp.p('<span class="after">');
				    
					htp.p('<a class="script" onclick="update_prop(document.getElementById(''ident'').value, ''PERMISSAOED'', this.nextElementSibling.title);"></a>');
					
					begin
						select propriedade into ws_grupo from object_attrib where cd_object = trim(prm_id) and cd_prop = 'PERMISSAOED';
					exception when others then
						ws_grupo := '';
					end;

					fcl.fakeoption('permissao-browser-ed', '', ws_grupo, 'lista-permissao-browser-op', 'N', 'S', prm_id, fun.lang('Lista de valores'), 'PERMISSAOED');
                   
				htp.p('</span>');
			htp.p('</li>');
			
			htp.p('<li>');
				
				htp.p('<span class="before">'||fun.lang('Bloqueio de exclus&atilde;o')||'</span>');
				htp.p('<span class="after">');
					
					htp.p('<a class="script" onclick="update_prop(document.getElementById(''ident'').value, ''PERMISSAOEX'', this.nextElementSibling.title);"></a>');
					begin
						select propriedade into ws_grupo from object_attrib where cd_object = trim(prm_id) and cd_prop = 'PERMISSAOEX';
					exception when others then
						ws_grupo := '';
					end;

					fcl.fakeoption('permissao-browser-ex', '', ws_grupo, 'lista-permissao-browser-op', 'N', 'S', prm_id, fun.lang('Lista de valores'), 'PERMISSAOEX');

				htp.p('</span>');
			htp.p('</li>');
			
			htp.p('<li>');

				htp.p('<span class="before">'||fun.lang('Bloqueio de adi&ccedil;&atilde;o')||'</span>');
				htp.p('<span class="after">');
					htp.p('<a class="script" onclick="update_prop(document.getElementById(''ident'').value, ''PERMISSAOAD'', this.nextElementSibling.title);"></a>');
					begin
						select propriedade into ws_grupo from object_attrib where cd_object = trim(prm_id) and cd_prop = 'PERMISSAOAD';
					exception when others then
						ws_grupo := '';
					end;
					fcl.fakeoption('permissao-browser-ad', '', ws_grupo, 'lista-permissao-browser-op', 'N', 'S', prm_id, fun.lang('Lista de valores'), 'PERMISSAOAD');
				htp.p('</span>');
			htp.p('</li>');

			htp.p('<li>');
				
				htp.p('<span class="before">'||fun.lang('Bloqueio de filtro')||'</span>');
				htp.p('<span class="after">');

					htp.p('<a class="script" onclick="update_prop(document.getElementById(''ident'').value, ''PERMISSAONOFILTER'', this.nextElementSibling.title);"></a>');
					begin
						select propriedade into ws_grupo from object_attrib where cd_object = trim(prm_id) and cd_prop = 'PERMISSAONOFILTER';
					exception when others then
						ws_grupo := '';
					end;

					fcl.fakeoption('permissao-browser-filter', '', ws_grupo, 'lista-permissao-browser-op', 'N', 'S', prm_id, fun.lang('Lista de valores'), 'PERMISSAONOFILTER');
					
				htp.p('</span>');
			htp.p('</li>');
			

			htp.p('<li>');
				htp.p('<span class="before">'||fun.lang('Bloqueio de destaque')||'</span>');
				htp.p('<span class="after">');
					htp.p('<a class="script" onclick="update_prop(document.getElementById(''ident'').value, ''PERMISSAODESTAQUE'', this.nextElementSibling.title);document.querySelector(''.itens'').setAttribute(''data-alterado'', ''T'');"></a>');
					begin
						select propriedade into ws_grupo from object_attrib where cd_object = trim(prm_id) and cd_prop = 'PERMISSAODESTAQUE';
					exception when others then
						ws_grupo := '';
					end;
					fcl.fakeoption('permissao-browser-destaque', '', ws_grupo, 'lista-permissao-browser-op', 'N', 'S', prm_id, fun.lang('Lista de valores'), 'PERMISSAODESTAQUE');
				htp.p('</span>');
			htp.p('</li>');



			htp.p('<li>');
				htp.p('<span class="before">'||fun.lang('Observa&ccedil;&atilde;o')||'</span>');
				htp.p('<span class="after">');
				htp.p('<textarea class="p_ds_objeto" onblur="update_prop(document.getElementById(''ident'').value, ''descritivo'', this.value);">'||ws_obj.ds_objeto||'</textarea>');
				htp.p('</span>');
			htp.p('</li>');

		htp.p('</ul>');

	htp.p('</div>');
	
	fcl.closer_menu;

exception 
	when ws_nouser then
		htp.p('Sem permiss&atilde;o!');
	when others then
    	htp.p(sqlerrm);
end properties;

end BRO;
/
show error