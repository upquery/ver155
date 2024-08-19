set scan off
create or replace package COM as

    procedure modal ( prm_id number );

	procedure report;

	procedure sendReport( prm_report varchar2, 
						  prm_email varchar2, 
						  prm_cc varchar2 default null, 
						  prm_assunto varchar2, 
						  prm_url varchar2 default null, 
						  prm_mimic varchar2 );

	procedure addreport ( prm_usuario varchar2 default null,
					      prm_assunto varchar2 default null,
						  prm_msg     varchar2 default null,
						  prm_tela    varchar2 default null,
						  prm_email    varchar2 default null );

	procedure deletereport ( prm_id number );

	procedure updatereport ( prm_id number,
							 prm_coluna varchar2 default null,
							 prm_valor  clob );

	procedure reportschedule (  prm_id varchar2 default null );

	procedure addreportschedule ( prm_id number, 
								  prm_semana varchar2, 
								  prm_mes varchar2, 
								  prm_hora varchar2, 
								  prm_quarter varchar2 );

	procedure deletereportschedule ( prm_id number );

	procedure updatereportschedule ( prm_id     number,
                         		 	 prm_coluna varchar2 default null,
						 		     prm_valor  varchar2 default null );

	procedure reportfilter ( prm_report varchar2 default null );

	procedure addreportfilter ( prm_id       number, 
								prm_usuario  varchar2,
								prm_visao    varchar2,
								prm_coluna   varchar2,
								prm_condicao varchar2,
								prm_conteudo varchar2 );

	procedure updatereportfilter ( prm_filter number, 
								   prm_campo  varchar2 default null,
								   prm_valor  varchar2 default null );

	procedure deletereportfilter ( prm_filter number );

	procedure reportexec;

end COM;
/
create or replace package body COM is

    procedure modal ( prm_id number ) as 

    ws_msg     varchar2(30000);
	ws_assunto varchar2(1000);
				  
begin

    select msg, assunto into ws_msg, ws_assunto from bi_report_list where id = prm_id;

    htp.p('<div class="modal" id="modal'||prm_id||'">');
        htp.p('<h2 style="font-family: var(--fonte-secundaria); font-size: 20px; margin: 10px 20px;">MENSAGEM DO EMAIL</h2>');
		htp.p('<div id="pell-editor'||prm_id||'" class="pell-bar"></div>');
		--falta default 
		--htp.p('<div class="default">'||ws_msg||'</div>');
		--htp.p('<input id="modal-output'||prm_id||'" type="hidden" name="content" value="'||htf.escape_sc(ws_msg)||'">');
		--htp.p('<trix-editor input="modal-output'||prm_id||'" id="modal-input'||prm_id||'" class="editable"></trix-editor>');
		--html visibel < with &lt; or &60; and > with &gt; or &62; 
		--modal.innerHTML = modal.innerHTML.replace(/</g, '&lt;').replace(/>/g, '&gt;')
		--modal.innerHTML = modal.innerHTML.replace(/&lt;/g, '<').replace(/&gt;/g, '>')
		htp.p('<div id="modal-output'||prm_id||'" class="editable" contenteditable="true" title="Aceita #[PARAMETRO_USUARIO], @[OBJETO_VALOR], #[VARIAVEL_AMBIENTE], $[SCREEN], $[USER]" onkeypress="var tamanho = this.innerHTML.toString().length; if(tamanho > 4000){ event.preventDefault(); return false;  } console.log(this.innerHTML.toString().length);">'||ws_msg||'</div>');
		htp.p('<div style="display: flex; width: 70%; margin: 0 auto;">');
			htp.p('<a class="addpurple" onclick="call(''updateReport'', ''prm_id='||prm_id||'&prm_coluna=msg&prm_valor=''+encodeURIComponent(document.getElementById(''modal-output'||prm_id||''').innerHTML), ''com'').then(function(res){ if(res.indexOf(''ok'') != -1){ alerta('''', TR_AL); document.getElementById(''modal'||prm_id||''').classList.remove(''expanded''); setTimeout(function(){ document.getElementById(''modal'||prm_id||''').remove(); }, 200); } else { alerta('''', TR_ER); } });">SALVAR</a>');
			htp.p('<a class="addpurple" onclick="document.getElementById(''modal'||prm_id||''').classList.remove(''expanded''); setTimeout(function(){ document.getElementById(''modal'||prm_id||''').remove(); }, 200);">FECHAR</a>');
	    htp.p('</div>');
	htp.p('</div>');

end modal;

procedure report as

    cursor crs_report is 
	select id, usuario, assunto, msg, tela, nm_objeto as nm_tela, email
	from bi_report_list
	left join objetos on cd_objeto = tela;
	ws_report crs_report%rowtype;

begin

	--usuario da base que vai copiar
	--fun.ret_var('COM_USER')
	--senha do usuário da base que vai copiar
	--prm_password => fun.ret_var('COM_PASS')
	--endereço da base que vai copiar
	--prm_address => fun.ret_var('COM_END')

	htp.p('<div class="searchbar">');
		htp.p('<a onclick="let fun = function(){ ajax(''list'', ''list_vconteudo'', ''prm_usuario='', false, ''attriblist''); } attReopen(fun, ''attriblist''); closeSideBar(''prefdrop''); document.getElementById(''prefdrop'').classList.toggle(''hover'');"><img src="dwu.fcl.download?arquivo=prop_140.svg" /></a>');
		--htp.p('<input placeholder="COM_USER" title="" value="'||fun.ret_var('COM_USER')||'" />');
		--htp.p('<input placeholder="COM_PASS" value="'||fun.ret_var('COM_PASS')||'" />');
		--htp.p('<input placeholder="COM_END" value="'||fun.ret_var('COM_END')||'" />');
	htp.p('</div>');

    htp.p('<table class="linha">');
			htp.p('<thead>');
				htp.p('<tr>');
				    htp.p('<th>EMAIL</th>');
					htp.p('<th>'||fun.lang('USU&Aacute;RIO')||'</th>');
					htp.p('<th>'||fun.lang('ASSUNTO')||'</th>');
					htp.p('<th>'||fun.lang('MENSAGEM')||'</th>');
					htp.p('<th>'||fun.lang('TELA')||'</th>');
					htp.p('<th></th>');
					htp.p('<th></th>');
					htp.p('<th></th>');
					htp.p('<th></th>');
				htp.p('</tr>');
			htp.p('</thead>');

			htp.p('<tbody id="ajax" >');
			
				open crs_report;
				    loop
					    fetch crs_report into ws_report;
					    exit when crs_report%notfound;
						htp.p('<tr id="'||ws_report.id||'">');
						    
							htp.p('<td>');
							    htp.p('<a class="script com_enviar" data-default="'||ws_report.email||'" title="email"></a>');
							    fcl.fakeoption('prm_email_'||ws_report.id||'', 'Email', ws_report.email, 'lista-email', 'N', 'S');
							htp.p('</td>');
							
							htp.p('<td>');
							    htp.p('<a class="script com_enviar" data-default="'||ws_report.usuario||'" title="usuario"></a>');
							    fcl.fakeoption('prm_usuario_'||ws_report.id||'', 'Usu&aacute;rio', ws_report.usuario, 'lista-usuarios', 'N', 'N');
							htp.p('</td>');
							
							htp.p('<td><input id="prm_assunto_'||ws_report.id||'" data-default="'||ws_report.assunto||'" onblur="requestDefault(''updateReport'', ''prm_id='||ws_report.id||'&prm_coluna=assunto&prm_valor=''+this.value, this, this.value);" value="'||ws_report.assunto||'" /></td>');

							--ajustar o default
							htp.p('<td title="clique para editar" class="com_modal" id="modalclick'||ws_report.id||'" style="cursor: pointer;">');
							    htp.p('<input class="readonly" value="'||replace(replace(regexp_replace(ws_report.msg, '<.+?>'), chr(34), ''), chr(39), '')||'" />');
							htp.p('</td>');

							htp.p('<td>');
							    htp.p('<a class="script com_enviar" data-default="'||ws_report.tela||'" title="tela"></a>');
		                        fcl.fakeoption('prm_tela_'||ws_report.id||'', 'Escolha uma tela', ws_report.tela, 'lista-telas-selecionadas', 'N', 'N', prm_desc => ws_report.nm_tela, prm_min => 1);
							htp.p('</td>');

							htp.p('<td class="com_enviar" title="ENVIAR">');
								htp.p('<svg style="margin: 0 2px; height: 24px; width: 24px; float: left;" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 488.721 488.721" style="enable-background:new 0 0 488.721 488.721;" xml:space="preserve"> <g> <g> <path d="M483.589,222.024c-5.022-10.369-13.394-18.741-23.762-23.762L73.522,11.331C48.074-0.998,17.451,9.638,5.122,35.086 C-1.159,48.052-1.687,63.065,3.669,76.44l67.174,167.902L3.669,412.261c-10.463,26.341,2.409,56.177,28.75,66.639 c5.956,2.366,12.303,3.595,18.712,3.624c7.754,0,15.408-1.75,22.391-5.12l386.304-186.982 C485.276,278.096,495.915,247.473,483.589,222.024z M58.657,446.633c-8.484,4.107-18.691,0.559-22.798-7.925 c-2.093-4.322-2.267-9.326-0.481-13.784l65.399-163.516h340.668L58.657,446.633z M100.778,227.275L35.379,63.759 c-2.722-6.518-1.032-14.045,4.215-18.773c5.079-4.949,12.748-6.11,19.063-2.884l382.788,185.173H100.778z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
							htp.p('</td>');

							htp.p('<td class="com_enviar" title="REGRAS">');
								htp.p('<svg style="margin: 0 2px; height: 24px; width: 24px; float: left;" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"width="550.801px" height="550.801px" viewBox="0 0 550.801 550.801" style="enable-background:new 0 0 550.801 550.801;"xml:space="preserve"> <g> <g> <path d="M277.425,402.116c-20.208,0-31.87,19.833-31.87,44.317c-0.2,24.88,11.853,43.934,31.681,43.934 c20.018,0,31.683-18.858,31.683-44.508C308.918,421.949,297.644,402.116,277.425,402.116z"/> <path d="M475.095,131.992c-0.032-2.526-0.833-5.021-2.568-6.993L366.324,3.694c-0.021-0.034-0.062-0.045-0.084-0.076 c-0.633-0.707-1.36-1.29-2.141-1.804c-0.232-0.15-0.475-0.285-0.718-0.422c-0.675-0.366-1.382-0.67-2.13-0.892 c-0.19-0.058-0.38-0.14-0.58-0.192C359.87,0.114,359.037,0,358.203,0H97.2C85.292,0,75.6,9.693,75.6,21.601v507.6 c0,11.913,9.692,21.601,21.6,21.601H453.6c11.908,0,21.601-9.688,21.601-21.601V133.202 C475.2,132.796,475.137,132.398,475.095,131.992z M147.382,513.691c-14.974,0-29.742-3.892-37.125-7.979l6.022-24.485 c7.963,4.082,20.216,8.164,32.843,8.164c13.613,0,20.799-5.643,20.799-14.196c0-8.169-6.21-12.825-21.956-18.457 c-21.766-7.583-35.962-19.644-35.962-38.687c0-22.354,18.668-39.461,49.57-39.461c14.776,0,25.661,3.111,33.431,6.613 l-6.613,23.904c-5.244-2.521-14.575-6.207-27.4-6.207c-12.836,0-19.045,5.822-19.045,12.63c0,8.358,7.38,12.05,24.289,18.463 c23.127,8.553,34.024,20.608,34.024,39.076C200.253,495.023,183.336,513.691,147.382,513.691z M332.237,534.284 c-18.657-5.442-34.204-11.074-51.701-18.468c-2.911-1.16-6.022-1.745-9.134-1.936c-29.542-1.936-57.14-23.715-57.14-66.482 c0-39.261,24.877-68.808,63.942-68.808c40.047,0,62.006,30.322,62.006,66.087c0,29.742-13.796,50.735-31.104,58.504v0.785 c10.115,2.922,21.39,5.253,31.684,7.378L332.237,534.284z M441.492,511.745h-81.833V380.737h29.742V486.86h52.091V511.745z M97.2,366.752V21.601h250.203v110.515c0,5.961,4.831,10.8,10.8,10.8H453.6l0.011,223.836H97.2z"/> <path d="M334.114,171.171c0.475-1.308,0.812-2.647,0.812-4.063c0-17.386-37.568-26.765-72.924-26.765 c-35.321,0-72.879,9.379-72.879,26.765c0,1.416,0.33,2.761,0.81,4.074l-0.188,0.335c-1.616,2.932-2.415,5.89-2.415,8.801v21.513 c0,3.312,1.042,6.492,2.89,9.498l-0.242,0.411c-1.762,3.056-2.647,6.151-2.647,9.208v21.508c0,3.208,0.983,6.286,2.731,9.208 l-0.084,0.134c-1.762,3.051-2.647,6.152-2.647,9.202v21.51c0,19.122,32.801,34.093,74.672,34.093 c41.916,0,74.717-14.971,74.717-34.093v-21.51c0-3.056-0.886-6.162-2.669-9.208l-0.073-0.118c1.734-2.927,2.742-6.004,2.742-9.218 v-21.508c0-3.061-0.886-6.167-2.669-9.218l-0.231-0.396c1.846-3.011,2.9-6.186,2.9-9.508v-21.513c0-2.911-0.812-5.877-2.415-8.81 L334.114,171.171z M328.715,282.509c0,12.351-27.38,26.093-66.712,26.093c-39.295,0-66.68-13.742-66.68-26.093v-20.231 c12.263,11.232,37.492,18.396,66.68,18.396c29.228,0,54.456-7.169,66.712-18.407V282.509z M328.715,242.455 c0,12.34-27.38,26.093-66.712,26.093c-39.295,0-66.68-13.753-66.68-26.093v-20.234c12.263,11.227,37.492,18.398,66.68,18.398 c29.228,0,54.456-7.172,66.712-18.409V242.455z M328.715,201.825c0,12.34-27.38,26.093-66.712,26.093 c-39.295,0-66.68-13.748-66.68-26.093v-17.9c11.984,10.156,39.772,15.422,66.68,15.422c26.944,0,54.72-5.266,66.712-15.422 V201.825z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
							htp.p('</td>');

							htp.p('<td class="com_enviar" title="AGENDAMENTO">');
								htp.p('<svg  style="margin: 0 2px; height: 24px; width: 24px; float: left;" height="512pt" viewBox="-34 0 512 512.04955" width="512pt" xmlns="http://www.w3.org/2000/svg"><path d="m.0234375 290.132812c-.02734375 121.429688 97.5703125 220.324219 218.9882815 221.898438 121.421875 1.574219 221.550781-94.753906 224.671875-216.144531 3.125-121.386719-91.917969-222.734375-213.257813-227.40625v-17.28125h17.066407c14.136718 0 25.597656-11.460938 25.597656-25.597657 0-14.140624-11.460938-25.601562-25.597656-25.601562h-51.199219c-14.140625 0-25.601563 11.460938-25.601563 25.601562 0 14.136719 11.460938 25.597657 25.601563 25.597657h17.066406v17.28125c-119.054687 4.707031-213.183594 102.507812-213.3359375 221.652343zm187.7343745-264.53125c0-4.714843 3.820313-8.535156 8.535157-8.535156h51.199219c4.710937 0 8.53125 3.820313 8.53125 8.535156 0 4.710938-3.820313 8.53125-8.53125 8.53125h-51.199219c-4.714844 0-8.535157-3.820312-8.535157-8.53125zm238.933594 264.53125c0 113.109376-91.691406 204.800782-204.800781 204.800782-113.105469 0-204.800781-91.691406-204.800781-204.800782 0-113.105468 91.695312-204.800781 204.800781-204.800781 113.054687.132813 204.667969 91.746094 204.800781 204.800781zm0 0"/><path d="m315.3125 127.402344c-57.828125-33.347656-129.046875-33.347656-186.878906 0-.136719.070312-.296875.070312-.441406.144531-.148438.078125-.214844.222656-.351563.308594-28.179687 16.4375-51.625 39.882812-68.0625 68.0625-.085937.136719-.222656.210937-.304687.347656-.085938.136719-.078126.300781-.148438.445313-33.347656 57.828124-33.347656 129.050781 0 186.878906.070312.144531.070312.300781.148438.445312.074218.144532.289062.347656.417968.535156 16.429688 28.097657 39.835938 51.472657 67.949219 67.875.136719.085938.214844.222657.351563.308594.136718.085938.433593.160156.648437.265625 57.714844 33.175781 128.71875 33.175781 186.433594 0 .214843-.105469.445312-.148437.648437-.265625.207032-.121094.214844-.222656.351563-.308594 28.117187-16.410156 51.523437-39.800781 67.949219-67.90625.128906-.1875.300781-.335937.417968-.539062.121094-.203125.078125-.296875.148438-.445312 33.347656-57.828126 33.347656-129.046876 0-186.878907-.070313-.144531-.070313-.296875-.148438-.441406-.074218-.148437-.21875-.214844-.304687-.34375-16.433594-28.183594-39.882813-51.632813-68.0625-68.070313-.136719-.085937-.214844-.222656-.351563-.308593-.136718-.082031-.261718-.039063-.410156-.109375zm49.777344 70.203125-7.050782 4.070312c-2.660156 1.515625-4.308593 4.339844-4.3125 7.402344-.007812 3.058594 1.625 5.890625 4.28125 7.417969 2.65625 1.523437 5.925782 1.507812 8.566407-.039063l7.058593-4.078125c11.027344 21.488282 17.332032 45.09375 18.488282 69.222656h-25.164063c-4.710937 0-8.53125 3.820313-8.53125 8.53125 0 4.714844 3.820313 8.535157 8.53125 8.535157h25.164063c-1.15625 24.128906-7.460938 47.730469-18.488282 69.222656l-7.058593-4.082031c-2.640625-1.546875-5.910157-1.5625-8.566407-.035156-2.65625 1.523437-4.289062 4.355468-4.28125 7.417968.003907 3.0625 1.652344 5.886719 4.3125 7.398438l7.050782 4.070312c-13.140625 20.265625-30.40625 37.53125-50.671875 50.671875l-4.070313-7.050781c-1.511718-2.660156-4.335937-4.308594-7.398437-4.3125-3.0625-.007812-5.894531 1.625-7.417969 4.28125-1.527344 2.65625-1.511719 5.925781.035156 8.566406l4.082032 7.058594c-21.492188 11.027344-45.09375 17.332031-69.222657 18.488281v-25.164062c0-4.710938-3.820312-8.53125-8.535156-8.53125-4.710937 0-8.53125 3.820312-8.53125 8.53125v25.164062c-24.128906-1.15625-47.734375-7.460937-69.222656-18.488281l4.078125-7.058594c1.546875-2.640625 1.5625-5.910156.039062-8.566406-1.527344-2.65625-4.359375-4.289062-7.417968-4.28125-3.0625.003906-5.886719 1.652344-7.402344 4.3125l-4.070313 7.050781c-20.265625-13.140625-37.53125-30.40625-50.667969-50.671875l7.046876-4.070312c2.660156-1.511719 4.308593-4.335938 4.316406-7.398438.007812-3.0625-1.628906-5.894531-4.285156-7.417968-2.652344-1.527344-5.921876-1.511719-8.566407.035156l-7.054687 4.082031c-11.03125-21.492187-17.335938-45.09375-18.492188-69.222656h25.164063c4.714843 0 8.535156-3.820313 8.535156-8.535157 0-4.710937-3.820313-8.53125-8.535156-8.53125h-25.164063c1.15625-24.128906 7.460938-47.734374 18.492188-69.222656l7.054687 4.078125c2.644531 1.546875 5.914063 1.5625 8.566407.039063 2.65625-1.527344 4.292968-4.359375 4.285156-7.417969-.007813-3.0625-1.65625-5.886719-4.316406-7.402344l-7.046876-4.070312c13.136719-20.265625 30.402344-37.53125 50.667969-50.671875l4.070313 7.050781c1.515625 2.660156 4.339844 4.308594 7.402344 4.316406 3.058593.003907 5.890624-1.628906 7.417968-4.285156 1.523438-2.65625 1.507813-5.921875-.039062-8.566406l-4.078125-7.054688c21.488281-11.03125 45.09375-17.335937 69.222656-18.492187v25.164062c0 4.714844 3.820313 8.535156 8.53125 8.535156 4.714844 0 8.535156-3.820312 8.535156-8.535156v-25.164062c24.128907 1.15625 47.730469 7.460937 69.222657 18.492187l-4.082032 7.054688c-1.546875 2.644531-1.5625 5.910156-.035156 8.566406 1.523438 2.65625 4.355469 4.289063 7.417969 4.285156 3.0625-.007812 5.886719-1.65625 7.398437-4.316406l4.070313-7.050781c20.265625 13.140625 37.53125 30.40625 50.671875 50.671875zm0 0"/><path d="m230.425781 266.101562v-86.902343c0-4.710938-3.820312-8.53125-8.535156-8.53125-4.710937 0-8.53125 3.820312-8.53125 8.53125v86.902343c-11.757813 4.15625-18.808594 16.179688-16.699219 28.46875 2.109375 12.285157 12.761719 21.269532 25.230469 21.269532s23.125-8.984375 25.230469-21.269532c2.109375-12.289062-4.941406-24.3125-16.695313-28.46875zm-8.535156 32.566407c-4.710937 0-8.53125-3.820313-8.53125-8.535157 0-4.710937 3.820313-8.53125 8.53125-8.53125 4.714844 0 8.535156 3.820313 8.535156 8.53125 0 4.714844-3.820312 8.535157-8.535156 8.535157zm0 0"/></svg>');
							htp.p('</td>');

							htp.p('<td>');
							    fcl.button_lixo('deleteReport','prm_id', ws_report.id, prm_tag => 'a', prm_pkg => 'COM');
							htp.p('</td>');

						htp.p('</tr>');
				    end loop;
				close crs_report;

			htp.p('</tbody>');
		htp.p('</table>');

		htp.p('<div id="modal-box" style="display: contents;"></div>');

    /*begin
		send_report( prm_to       => 'joao@upquery.com', 
		prm_cc       => '', 
		prm_message  => 'teste de msg', 
		prm_subject  => 'assunto', 
		prm_id       => 'SRC_6624349171201025734', 
		prm_mimic    =>  'JOAO', 
		prm_usuario  => 'DWU', 
		prm_password => 'virgilino1988', 
		prm_address  => 'update.upquery.com/pls', 
		prm_filename => 'relatorio.pdf' 
	);
	exception when others then
		insert into err_txt values('Erro no relatório');
		commit;
	end;*/

end report;

procedure addReport ( prm_usuario varchar2 default null,
                      prm_assunto varchar2 default null,
					  prm_msg     varchar2 default null,
					  prm_tela    varchar2 default null,
					  prm_email    varchar2 default null ) as

	ws_count number := 0; 
	ws_error exception;				  
	ws_id    number := 0;				  
begin

    select max(id) into ws_id from bi_report_list;

	if nvl(ws_id, 0) = 0 then
        ws_id := 1;
	else
        ws_id := ws_id+1;
	end if;

    insert into bi_report_list (id, usuario, assunto, msg, tela, email) values (ws_id, prm_usuario, prm_assunto, prm_msg, prm_tela, prm_email);

	ws_count := SQL%ROWCOUNT;
			
	if ws_count = 1 then
		commit;
	else
		rollback;
		raise ws_error;
	end if;

	htp.p('ok');

exception 
    when ws_error then
        htp.p('ERRO AO INSERIR REPORT');
	when others then
	    htp.p('ERRO '||SQLERRM);
end addReport;

procedure deleteReport ( prm_id number ) as

    ws_count number := 0; 
	ws_error exception;				  

begin

    delete from bi_report_list where id = prm_id;

	ws_count := SQL%ROWCOUNT;
			
	if ws_count = 1 then
		commit;

        delete from bi_report_schedule where report_id = prm_id;
		commit;

	else
		rollback;
		raise ws_error;
	end if;

	htp.p('ok');

exception 
    when ws_error then
        htp.p('ERRO AO EXCLUIR REPORT');
	when others then
	    htp.p('ERRO '||SQLERRM);
end deleteReport;

procedure updateReport ( prm_id number,
                         prm_coluna varchar2 default null,
						 prm_valor  clob ) as

    ws_count number := 0; 
	ws_error exception;				  

begin

    case prm_coluna
		when 'tela' then

			update bi_report_list set tela = prm_valor
			where id = prm_id;

		when 'usuario' then

			update bi_report_list set usuario = prm_valor
			where id = prm_id;

		when 'assunto' then

			update bi_report_list set assunto = prm_valor
			where id = prm_id;

		when 'msg' then
			
			update bi_report_list set msg = to_clob(prm_valor)
			where id = prm_id;

		when 'email' then
			
			update bi_report_list set email = prm_valor
			where id = prm_id;

	end case;

	ws_count := SQL%ROWCOUNT;
			
	if ws_count = 1 then
		commit;
	else
		rollback;
		raise ws_error;
	end if;

	htp.p('ok');

exception 
    when ws_error then
        htp.p('ERRO AO ATUALIZAR O REPORT');
	when others then
	    htp.p('ERRO '||SQLERRM);
end updateReport;

procedure reportSchedule (  prm_id varchar2 default null ) as

    cursor crs_schedules is
	select id, report_id, semana, mes, hora, quarter, ultimo_status, ultima_data
	from bi_report_schedule
	where report_id = prm_id;

	ws_schedule crs_schedules%rowtype;
	ws_desc varchar2(40);
begin
    
	htp.p('<input type="hidden" id="prm_id" value="'||prm_id||'">');

	htp.p('<table class="linha">');
		htp.p('<thead>');
			htp.p('<tr >');
				htp.p('<th>'||fun.lang('DIAS/SEMANA')||'</th>');
				htp.p('<th>'||fun.lang('M&Ecirc;S')||'</th>');
				htp.p('<th>'||fun.lang('HORAS')||'</th>');
				htp.p('<th>'||fun.lang('INTERVALO DE TEMPO')||'</th>');
				--htp.p('<th>'||fun.lang('ÚLTIMA EXECU&Ccedil;&Atilde;O')||'</th>');
			htp.p('</tr>');
		htp.p('</thead>');
		htp.p('<tbody id="etl-schedule">');


		open crs_schedules;
			loop
				fetch crs_schedules into ws_schedule;
				exit when crs_schedules%notfound;
				htp.p('<tr id="'||ws_schedule.id||'">');

					htp.p('<td>');
						htp.p('<a class="script com_enviar" title="semana"></a>');
						fcl.fakeoption(ws_schedule.id||'-semanas', '', ws_schedule.semana, 'lista-semanas', 'N', 'S', prm_id, fun.lang('SEMANAS'), ws_schedule.id||'|'||ws_schedule.semana);
					htp.p('</td>');
					
					htp.p('<td>');
						htp.p('<a class="script com_enviar" title="mes"></a>');
						fcl.fakeoption(ws_schedule.id||'-mes', '', ws_schedule.mes, 'lista-meses', 'N', 'S', prm_id, fun.lang('MESES'), ws_schedule.id||'|'||ws_schedule.mes);
					htp.p('</td>');
					
					htp.p('<td>');
						htp.p('<a class="script com_enviar" title="hora"></a>');
						fcl.fakeoption(ws_schedule.id||'-horas', '', ws_schedule.hora, 'lista-horas', 'N', 'S', prm_id, fun.lang('HORAS'), ws_schedule.id||'|'||ws_schedule.hora);
					htp.p('</td>');

					htp.p('<td>');
						htp.p('<select id="etl_quarter" onchange="call(''updateReportSchedule'', ''prm_id='||ws_schedule.id||'&prm_coluna=quarter&prm_valor=''+this.value, ''COM'').then(function(res){ if(res.indexOf(''ok'') == -1){ alerta(''feed-fixo'', TR_ER); } else { alerta(''feed-fixo'', TR_AL); } });">');

							if ws_schedule.quarter = 1 then
								htp.p('<option value="1" selected>1m</option>');
							else
								htp.p('<option value="1">1m</option>');
							end if;
							
							if ws_schedule.quarter = 5 then
								htp.p('<option value="5" selected>5m</option>');
							else
								htp.p('<option value="5">5m</option>');
							end if;
							
							if ws_schedule.quarter = 10 then
								htp.p('<option value="10" selected>10m</option>');
							else
								htp.p('<option value="10">10m</option>');
							end if;
							
							if ws_schedule.quarter = 15 then
								htp.p('<option value="15" selected>15m</option>');
							else
								htp.p('<option value="15">15m</option>');
							end if;
							
							if ws_schedule.quarter = 20 then
								htp.p('<option value="20" selected>20m</option>');
							else
								htp.p('<option value="20">20m</option>');
							end if;
							
							if ws_schedule.quarter = 30 then
								htp.p('<option value="30" selected>30m</option>');
							else
								htp.p('<option value="30">30m</option>');
							end if;
							
							if ws_schedule.quarter = 60 then
								htp.p('<option value="60" selected>'||fun.lang('NA HORA')||'</option>');
							else
								htp.p('<option value="60">'||fun.lang('NA HORA')||'</option>');
							end if;
							
						htp.p('</select>');
					htp.p('</td>');

					htp.p('<td>');
						fcl.button_lixo('deleteReportSchedule','prm_id', ws_schedule.id, prm_tag => 'a', prm_pkg => 'COM');
					htp.p('</td>');
					
				htp.p('</tr>');
			end loop;
		close crs_schedules;
		
		htp.p('</tbody>');
	htp.p('</table>');

	htp.p('<script>');
		htp.p('document.addEventListener(function(e){ console.log(''teste'');');
			htp.p('if(e.target.classList.contains(''script'')){');
				htp.p('var alvo = e.target; var parente = alvo.parentNode.id; ');
				htp.p('call(''updateReportSchedule'', ''prm_id=''+parente+''&prm_coluna=''+alvo.title+''&prm_valor=''+this.value, ''COM'').then(function(res){ 
					if(res.indexOf(''ok'') == -1){ 
						alerta(''feed-fixo'', TR_ER); 
					} else { 
						alerta(''feed-fixo'', TR_AL); 
					} 
				});');
			htp.p('}');
		htp.p('});');
	htp.p('</script>');
		
	htp.p('<div class="listar">');
		htp.p('<a onclick="call(''report'', '''', ''COM'').then(function(resposta){ document.getElementById(''content'').innerHTML = resposta; call(''menu'', ''prm_menu=report'').then(function(resp){ document.getElementById(''painel'').innerHTML = resp; }); });">'||fun.lang('VOLTAR')||'</a>');
	htp.p('</div>');

end reportSchedule;

procedure addReportSchedule ( prm_id number, 
                              prm_semana varchar2, 
							  prm_mes varchar2, 
							  prm_hora varchar2, 
							  prm_quarter varchar2 ) as
    ws_count number := 0; 
	ws_error exception;				  
	ws_id    number := 0;				  
begin

    select max(id) into ws_id from bi_report_schedule;

	if nvl(ws_id, 0) = 0 then
        ws_id := 1;
	else
        ws_id := ws_id+1;
	end if;

    insert into bi_report_schedule (id, report_id, semana, mes, hora, quarter) 
	values (ws_id, prm_id, prm_semana, prm_mes, prm_hora, prm_quarter);

	ws_count := SQL%ROWCOUNT;
			
	if ws_count = 1 then
		commit;
	else
		rollback;
		raise ws_error;
	end if;

	htp.p('ok');

exception 
    when ws_error then
        htp.p('ERRO AO INSERIR HOR&Aacute;RIO DO REPORT');
	when others then
	    htp.p('ERRO '||SQLERRM);
end addReportSchedule;

procedure deleteReportSchedule ( prm_id number ) as

    ws_count number := 0; 
	ws_error exception;				  

begin

    delete from bi_report_schedule where id = prm_id;

	ws_count := SQL%ROWCOUNT;
			
	if ws_count = 1 then
		commit;
	else
		rollback;
		raise ws_error;
	end if;

	htp.p('ok');

exception 
    when ws_error then
        htp.p('ERRO AO EXCLUIR HORÁRIO REPORT');
	when others then
	    htp.p('ERRO '||SQLERRM);
end deleteReportSchedule;

procedure updateReportSchedule ( prm_id     number,
                         		 prm_coluna varchar2 default null,
						 		 prm_valor  varchar2 default null ) as

    ws_count number := 0; 
	ws_error exception;				  

begin

    case prm_coluna
		when 'semana' then

			update bi_report_schedule set semana = prm_valor
			where id = prm_id;

		when 'mes' then

			update bi_report_schedule set mes = prm_valor
			where id = prm_id;

		when 'hora' then

			update bi_report_schedule set hora = prm_valor
			where id = prm_id;

		when 'quarter' then
			
			update bi_report_schedule set quarter = prm_valor
			where id = prm_id;

		when 'ultimo_status' then
			
			update bi_report_schedule set ultimo_status = prm_valor
			where id = prm_id;

		when 'ultima_data' then
			
			update bi_report_schedule set ultima_data = prm_valor
			where id = prm_id;
	end case;

	ws_count := SQL%ROWCOUNT;
			
	if ws_count = 1 then
		commit;
	else
		rollback;
		raise ws_error;
	end if;

	htp.p('ok');

exception 
    when ws_error then
        htp.p('ERRO AO ATUALIZAR O REPORT');
	when others then
	    htp.p('ERRO '||SQLERRM);
end updateReportSchedule;

procedure reportFilter ( prm_report varchar2 default null ) as 

    cursor crs_filtros is
	select id, micro_visao, coluna, condicao, valor
	from   bi_report_filter
	where  report_id = prm_report;

	ws_filtro crs_filtros%rowtype;

begin

    htp.p('<table class="linha">');
	    htp.p('<thead>');
			htp.p('<tr>');
				htp.p('<th>VIEW</th>');
				htp.p('<th>'||fun.lang('COLUNA')||'</th>');
				htp.p('<th>'||fun.lang('CONDI&Ccedil;&Atilde;O')||'</th>');
				htp.p('<th>'||fun.lang('VALOR')||'</th>');
				htp.p('<th></th>');
			htp.p('</tr>');
		htp.p('</thead>');
		htp.p('<tbody class="ajax">');
			open crs_filtros;
				loop
					fetch crs_filtros into ws_filtro;
					exit when crs_filtros%notfound;
					htp.p('<tr>');
						
						htp.p('<td>'||ws_filtro.micro_visao||'</td>');
						
						htp.p('<td>');
                            htp.p('<a class="script" onclick="call(''updateReportFilter'',''prm_filter='||ws_filtro.id||'&prm_campo=coluna&prm_valor=''+encodeURIComponent(document.getElementById(''filtro-coluna-'||ws_filtro.id||''').title), ''COM'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_AL); } });"></a>');
							fcl.fakeoption('filtro-coluna-'||ws_filtro.id, '', ws_filtro.coluna, 'lista-colunas', 'N', 'N', ''||ws_filtro.micro_visao||'', '');
						htp.p('</td>');
							
						htp.p('<td>');
							htp.p('<a class="script" onclick="call(''updateReportFilter'',''prm_filter='||ws_filtro.id||'&prm_campo=condicao&prm_valor=''+encodeURIComponent(document.getElementById(''filtro-condicao-'||ws_filtro.id||''').title), ''COM'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_AL); } });"></a>');
							fcl.fakeoption('filtro-condicao-'||ws_filtro.id||'', '', ws_filtro.condicao, 'lista-condicoes', 'N', 'N', '', '', '', fun.dcondicao(ws_filtro.condicao));
						htp.p('</td>');

						htp.p('<td>');
							htp.p('<a class="script" onclick="call(''updateReportFilter'',''prm_filter='||ws_filtro.id||'&prm_campo=conteudo&prm_valor=''+encodeURIComponent(document.getElementById(''filtro-conteudo-'||ws_filtro.id||''').title), ''COM'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_AL); } });"></a>');
							fcl.fakeoption('filtro-conteudo-'||ws_filtro.id, '', ws_filtro.valor, 'lista-valores', 'S', 'N', ''||ws_filtro.micro_visao||'', '', 'filtro-coluna-'||ws_filtro.id, ws_filtro.valor);
						htp.p('</td>');
						
						--htp.p('<td>'||ws_filtro.coluna||'</td>');
						--htp.p('<td>'||ws_filtro.condicao||'</td>');
						--htp.p('<td>'||ws_filtro.valor||'</td>');
						htp.p('<td>');
							fcl.button_lixo('deleteReportFilter','prm_filter', ws_filtro.id, prm_pkg => 'COM');
						htp.p('</td>');
					htp.p('</tr>');
				end loop;
			close crs_filtros;
		htp.p('</tbody>');
	htp.p('</table>');

	htp.p('<div class="listar">');
		htp.p('<a onclick="call(''report'', '''', ''COM'').then(function(resposta){ document.getElementById(''content'').innerHTML = resposta; call(''menu'', ''prm_menu=report'').then(function(resp){ document.getElementById(''painel'').innerHTML = resp; }); });">'||fun.lang('VOLTAR')||'</a>');
	htp.p('</div>');

end reportFilter;

procedure addReportFilter ( prm_id       number, 
                            prm_usuario  varchar2,
							prm_visao    varchar2,
							prm_coluna   varchar2,
							prm_condicao varchar2,
							prm_conteudo varchar2 ) as
    ws_count number := 0; 
	ws_error exception;				  
	ws_id    number := 0;				  
begin

    select max(id) into ws_id from bi_report_filter;

	if nvl(ws_id, 0) = 0 then
        ws_id := 1;
	else
        ws_id := ws_id+1;
	end if;

    insert into bi_report_filter (coluna, condicao, id, micro_visao, nm_usuario, report_id, valor) 
	values (prm_coluna, prm_condicao, ws_id, prm_visao, prm_usuario, prm_id, prm_conteudo);

	ws_count := SQL%ROWCOUNT;
			
	if ws_count = 1 then
		commit;
	else
		rollback;
		raise ws_error;
	end if;

	htp.p('ok');

exception 
    when ws_error then
        htp.p('ERRO AO INSERIR REGRA DO REPORT');
	when others then
	    htp.p('ERRO '||SQLERRM);
end addReportFilter;

procedure updateReportFilter ( prm_filter number, 
							   prm_campo  varchar2 default null,
							   prm_valor  varchar2 default null ) as

	ws_count number;

begin

    case prm_campo

	when 'coluna' then

		update bi_report_filter
		set coluna = prm_valor
		where id = prm_filter;
		--commit;

	when 'condicao' then

		update bi_report_filter
		set condicao = prm_valor
		where id = prm_filter;

	when 'valor' then

		update bi_report_filter
		set valor = prm_valor
		where id = prm_filter;

	when 'micro_visao' then

		update bi_report_filter
		set valor = prm_valor
		where id = prm_filter;

	end case;

	ws_count := sql%rowcount;

	if ws_count = 1 then
		htp.p('ok');
		commit;
	else
		htp.p('erro');
		rollback;
	end if;

exception when others then
	htp.p('erro');
	rollback;
end updateReportFilter;


procedure deleteReportFilter ( prm_filter number ) as

	ws_count number;

begin

    delete from bi_report_filter
	where id = prm_filter;

	ws_count := sql%rowcount;

	if ws_count = 1 then
		htp.p('ok');
		commit;
	else
		htp.p('erro');
		rollback;
	end if;

exception when others then
	htp.p('erro');
	rollback;
end deleteReportFilter;


procedure reportExec as 

    cursor crs_tarefas is
    select t1.id, t1.msg, t1.assunto, t1.tela, t1.usuario, t1.email, t2.report_id, t2.semana, t2.mes, t2.hora, t2.quarter, t2.ultimo_status, t2.ultima_data
    from   bi_report_schedule t2
	left join bi_report_list t1 on t1.id = t2.report_id;

    ws_reg_online       varchar2(100);
    ws_timeout          exception;
    ws_erro             varchar2(4000);
    ws_vartemp          varchar2(200);
    ws_try              number;
    ws_check            number     := 0;

    ws_date             date;
    ws_semana           varchar2(2);
    ws_mes              varchar2(2);
    ws_hora             varchar2(2);
    ws_quarter          varchar2(2);
 
    ws_owner            varchar2(90);
    ws_name             varchar2(90);
    ws_line             number;
    ws_caller           varchar2(90);

	ws_clob_length      number;
	ws_clob_start       number := 1;
	ws_clob_piecs       number := 2000;

	ws_url				varchar2(800);
	ws_parametros       varchar2(800) := '';

	ws_token            varchar2(80);
 
 BEGIN

    ws_date    := sysdate;
    ws_semana  := to_char(ws_date,'D');
    ws_mes     := to_char(ws_date,'MM');
    ws_hora    := to_char(ws_date,'HH24');
    ws_quarter := to_char(ws_date,'MI');

    for ac_tarefas in crs_tarefas loop
        exit when crs_tarefas%notfound;
		
		if nvl(ac_tarefas.semana, 'N/A') <> 'N/A' and nvl(ac_tarefas.mes, 'N/A') <> 'N/A' and nvl(ac_tarefas.hora, 'N/A') <> 'N/A' and (mod(ws_quarter, ac_tarefas.quarter) = 0 or (ws_quarter = '00' and ac_tarefas.quarter = '60')) then

		select sum(valor) into ws_check from(
			select count(column_value) as valor from table(fun.vpipe(ac_tarefas.semana)) where column_value = ws_semana
			union all
			select count(column_value) as valor from table(fun.vpipe(ac_tarefas.mes)) where column_value = ws_mes
			union all
			select count(column_value) as valor from table(fun.vpipe(ac_tarefas.hora)) where column_value = ws_hora
		);

		if ws_check = 3 then
			begin
				for s in (select column_value as tela from table(fun.vpipe(ac_tarefas.tela))) loop

					/*ws_clob_length := DBMS_LOB.getlength (ac_tarefas.msg);

					while ws_clob_start <= ws_clob_length loop
						ws_msg := ws_msg||fun.xexec(fun.subpar(DBMS_LOB.SUBSTR(ac_tarefas.msg, ws_clob_piecs, ws_clob_start), s.tela), s.tela);
						ws_clob_start   := ws_clob_start + ws_clob_piecs;
					end loop;*/

					--trim((Select Sid From V$session Where Audsid = Sys_Context('userenv','sessionid'))||(Select Serial# From V$session Where Audsid = Sys_Context('userenv','sessionid'))||to_char(sysdate,'yymmddhhmiss')) into ws_id from dual;

					--select to_char(sysdate,'yymmddhhmiss') into ws_token from dual;

					--ws_token := '1451';

					
					--gbl.setUsuario(ws_token, ac_tarefas.usuario);


					--$ parametro de usuário
					--@ pega valor do objeto valor
					--# pega variavel de ambiente
					--replace de variaveis como objeto valor, user e screen
					
					sendReport(ac_tarefas.id, ac_tarefas.email, '', ac_tarefas.assunto, s.tela, ac_tarefas.usuario );
					
					/*send_report(
						prm_to       => ac_tarefas.email, 
						prm_cc       => '', 
						prm_message  => ws_msg, 
						prm_subject  => ac_tarefas.assunto, 
						prm_url      => ws_url, 
						prm_mimic    => ac_tarefas.usuario, 
						--usuario da base que vai copiar
						prm_usuario => fun.ret_var('COM_USER'),
						--senha do usuário da base que vai copiar
						prm_password => fun.ret_var('COM_PASS'),
						--endereço da base que vai copiar
						prm_address => fun.ret_var('COM_END'), 
						prm_filename => 'relatorio.pdf' 
				    );*/

				end loop;
			exception when others then
				insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - COM', user, 'ERRO');
				commit;
			end;

		end if;

		end if;

    end loop;

 exception when others then
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - COM', user, 'ERRO');
    commit;
END reportExec;

procedure sendReport( prm_report varchar2,
					  prm_email varchar2, 
					  prm_cc varchar2 default null, 
					  prm_assunto varchar2, 
					  prm_url varchar2 default null, 
					  prm_mimic varchar2 ) as

	ws_parametros varchar2(12000);
	ws_url        varchar2(800);
	ws_token      varchar2(80);
	ws_msg        varchar2(18000);

begin

	for i in(select coluna, decode(trim(condicao),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]') as condicao, valor from bi_report_filter where report_id = prm_report) loop
		ws_parametros := ws_parametros||'|'||i.coluna||'|'||i.condicao||i.valor;
	end loop;

	if nvl(ws_parametros, 'N/A') <> 'N/A' then
		ws_parametros := substr(ws_parametros, 2, length(ws_parametros)-1);
	end if;

	delete from bi_sessao where valor = trim(upper(prm_mimic)) and cod like ('ANONYMOUS%');
	commit;

	ws_token := gbl.retToken(prm_mimic, prm_url);

	if nvl(prm_url, 'N/A') = 'N/A' then
		ws_url := 'N/A';
	else
		ws_url := '/dwu.fcl.show_screen?prm_screen='||prm_url||'&prm_parametro='||ws_parametros||'&prm_clear=R&prm_token='||ws_token;
	end if;

	select msg into ws_msg from bi_report_list where id = prm_report;

	ws_msg := fun.subpar(replace(replace(ws_msg, '$[SCREEN]', fun.nomeObjeto(prm_url)), '$[USER]', prm_mimic), prm_url);


	send_report(
		prm_to       => prm_email, 
		prm_cc       => prm_cc, 
		prm_message  => ws_msg, 
		prm_subject  => prm_assunto, 
		prm_url      => ws_url, 
		prm_mimic    => prm_mimic, 
		--usuario da base que vai copiar
		prm_usuario => fun.ret_var('COM_USER'),
		--senha do usuário da base que vai copiar
		prm_password => fun.ret_var('COM_PASS'),
		--endereço da base que vai copiar
		prm_address => fun.ret_var('COM_END'), 
		prm_filename => 'relatorio.pdf' 
	);

	htp.p('ok');
exception when others then
	htp.p('Error');
end sendReport;

/*create or replace procedure send_report( prm_to       varchar2 default null,
                                         prm_cc       varchar2 default null,
                                         prm_message  varchar2 default null, 
                                         prm_subject  varchar2 default null,
                                         prm_url       varchar2 default null, 
                                         prm_mimic    varchar2 default null,
                                         prm_usuario  varchar2 default 'DWU',
                                         prm_password varchar2 default null,
                                         prm_address  varchar2 default null,
                                         prm_filename varchar2 default 'relatorio.pdf' ) as
    ws_send varchar2(4000);
begin

    ws_send := '{ ';

    --DESTINATÁRIO
    ws_send := ws_send||'"to":[ "'||prm_to||'"], ';

    --CÓPIA OCULTA
    if nvl(prm_cc, 'N/A') <> 'N/A' then
        ws_send := ws_send||'"toCc":[ "'||prm_cc||'"], ';
    end if;

    --CORPO DO EMAIL, MENSAGEM PRINCIPAL
    ws_send := ws_send||'"message": "'||replace(replace(replace(replace(replace(prm_message, CHR(10), ''), CHR(13), ''), CHR(13)||CHR(10), ''), '\n', ''), '"', '\"')||'", ';

    --ASSUNTO
    ws_send := ws_send||'"subject": "'||prm_subject||'", ';

    --ID DA TELA UTILIZADA
    --nova versão
    if prm_url <> 'N/A' then
        ws_send := ws_send||'"urls": [{"url": "http://'||prm_address||prm_url||'", "user": "'||prm_usuario||'", "password": "'||prm_password||'", "attachmentName": "'||prm_filename||'"}] ';
    else
        ws_send := ws_send||'"urls": "" ';
    end if;

    --USUÁRIO QUE VAI FAZER LOGIN, DEFAULT DWU
    --ws_send := ws_send||'"urlUser": "'||prm_usuario||'", ';

    --SENHA DO USUÁRIO
    --ws_send := ws_send||'"urlPassword": "'||prm_password||'", ';

    --NOME QUE VAI FICAR NO ANEXO
    --ws_send := ws_send||' "attachmentName": "'||prm_filename||'" ';

    ws_send := ws_send||' }';

    --ENDEREÇO DA FERRAMENTA DE ENVIO, REPORT É O PRINT DA TELA
    select XT_HTTP.doApiPost('http://backend.upquery.com/api/v1/report', '9193c7b5a2636edb8637927c787f4975', null, null, ws_send) into ws_send from dual;

    --GRANT PARA ACESSO A FERRAMENTA
    --    begin
    --    dbms_java.grant_permission(
    --       grantee           => 'DWU'                       -- username
    --     , permission_type   => 'SYS:java.net.SocketPermission' -- connection permission
    --     , permission_name   => 'backend.upquery.com:80'                     -- connection address and port
    --     , permission_action => 'connect,resolve'               -- types
    --    );

    --    end;


exception when others then
    insert into err_txt values(DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' mimic => '||prm_mimic||' usuario => '||prm_usuario);
    commit;
end send_report; */

end COM;
/
show error