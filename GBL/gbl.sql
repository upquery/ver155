set scan off
/* 
 * package de variaveis globais 
 * 20/04/2020
*/

create or replace package gbl as

    function getUsuario return varchar2;

    procedure setUsuario ( prm_usuario varchar2 default null,
                           prm_mimic   varchar2 default null );

    function getNivel ( prm_usuario varchar2 default null ) return varchar2;

    --function setNivel ( prm_usuario varchar2 ) return varchar2;

    procedure getToken ( prm_usuario varchar2, prm_screen varchar2 default null );

    function retToken ( prm_usuario varchar2, prm_screen varchar2 default null ) return varchar2;

    procedure getVersion;

    function getLang return varchar2;

end gbl;
/
create or replace package body gbl as

    --usuario     varchar2(80) := NVL(FUN.RET_VAR('USUARIO', USER), USER);
    usuario     varchar2(80)/* := nvl(fun.ret_var('USUARIO', Owa_Cookie.Get('SESSION').Vals(1)), 'ENDSESSION')*/;
    --usuario     varchar2(80) := 'TESTE';

    nivel       varchar2(1)  := gbl.getNivel(getUsuario);
    --usuario     varchar2(80) := user;
    --linguagem   varchar2(80) := nvl(fun.ret_var(Owa_Cookie.Get('SESSION').Vals(1)), 'PORTUGUESE');
    
    --linguagem   varchar2(80) := gbl.getLang;
    version     varchar2(20) := '1.5.5';

    function getUsuario return varchar2 as

        ws_id varchar2(20);
        ws_user varchar2(80) := 'NOUSER';

    begin

        if nvl(fun.ret_var('XE'), 'N') = 'S' then
            return user;
        end if;

        begin
            ws_user := fun.getSessao(Owa_Cookie.Get('SESSION').Vals(1));
        exception when others then
            select Sys_Context('userenv','sid') into ws_id From dual;
            ws_user := fun.getSessao('ANONYMOUS'||ws_id);
        end;

        return nvl(ws_user, 'NOUSER');
    exception when others then
        return ws_user;
    end getUsuario;


    procedure setUsuario ( prm_usuario varchar2 default null,
                           prm_mimic   varchar2 default null ) as

    begin

        fun.setSessao(prm_usuario, prm_mimic);

    end setUsuario;

    function getNivel ( prm_usuario varchar2 default null ) return varchar2 as

        ws_show varchar2(1);
    
    begin

        if nvl(prm_usuario, 'N/A') = 'N/A' then
            return nivel;
        else
            select show_only into ws_show from usuarios where usu_nome = prm_usuario;
            return ws_show;
        end if;
    exception when others then
        return 'N';
    end getNivel;

    /*function setNivel ( prm_usuario varchar2 ) return varchar2 as

        ws_show varchar2(1);

    begin

        select show_only into ws_show from usuarios where usu_nome = prm_usuario;

        return ws_show;
    exception when others then
        return 'N';
    end setNivel;*/

    procedure getToken ( prm_usuario varchar2, prm_screen varchar2 default null ) as

        ws_token varchar2(100) := '0';
        ws_test  varchar2(10);
    begin

        /*ws_test := pwd_vrf(prm_usuario, prm_password);

	    if ws_test = 'Y' then*/

           /*   update bi_token set status = 'F' where status = 'D' and usuario = prm_usuario and nvl(tela, 'N/A') = nvl(prm_screen, 'N/A');
                commit;
            */

            ws_token := fun.randomCode(80);
            
            --select to_char(sysdate,'ss')||round(dbms_random.value(10,99))||to_char(sysdate,'dd')||round(dbms_random.value(10,99))||to_char(sysdate,'yy')||round(dbms_random.value(10,99))||to_char(sysdate,'mmmi')||round(dbms_random.value(10,99)) into ws_token from dual;
            insert into bi_token values(ws_token, prm_usuario, sysdate, 'D', prm_screen);
            commit;

        /*end if;*/

        htp.p(ws_token);
    exception when others then
         htp.p('0');
    end getToken;

    function retToken ( prm_usuario varchar2, prm_screen varchar2 default null ) return varchar2 as

        ws_token varchar2(100) := '0';
        ws_test  varchar2(10);
    begin
            update bi_token set status = 'F' where status = 'D' and usuario = prm_usuario and nvl(tela, 'N/A') = nvl(prm_screen, 'N/A');
            commit;

        ws_token := fun.randomCode(80);
        
        insert into bi_token values(ws_token, prm_usuario, sysdate, 'D', prm_screen);
        commit;

        return ws_token;
    exception when others then
        return '0';
    end retToken;

    procedure getVersion as

    begin

        htp.p(version);

    end getVersion;

    function getLang return varchar2 as

        ws_valor varchar2(80) := 'PORTUGUESE';

    begin
        
        if nvl(fun.ret_var('LANG'), 'N') = 'S' then
            select propriedade into ws_valor from object_attrib where owner = gbl.getUsuario and cd_prop = 'LINGUAGEM';
        end if;

        return nvl(ws_valor, 'PORTUGUESE');
    exception when others then
        return 'PORTUGUESE';
    end getLang;


end gbl;
/
show error