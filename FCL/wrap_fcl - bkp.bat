wrap iname=fcl.sql      oname=plb/fcl.plb
wrap iname=fcl_head.sql oname=plb/fcl_head.plb
sqlplus dwu/zynaps1988@DESENV155 @plb/fcl_head.plb
sqlplus dwu/zynaps1988@DESENV155 @plb/fcl.plb
time
