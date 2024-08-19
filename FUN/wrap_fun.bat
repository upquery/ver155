wrap iname=fun_head.sql oname=plb/fun_head.plb
wrap iname=fun.sql oname=plb/fun.plb
sqlplus dwu/zynaps1988@DESENV155  @plb/fun_head.plb
sqlplus dwu/zynaps1988@DESENV155  @plb/fun.plb
time

