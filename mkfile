BUILTINS=

</$objtype/mkfile

CODE=arith.c ctl.c proc.c var.c
CO=arith.$O ctl.$O proc.$O var.$O
FO=squint.$O alloc.$O bltin.$O compile.$O const.$O declare.$O error.$O \
	lex.$O main.$O node.$O symbol.$O type.$O xec.$O
#SO=space.$O fmount.$O
#LIBO=libio.$O liblib.$O libg.$O liblayer.$O
SO=space.$O
LIBO=libio.$O liblib.$O

CFLAGS=-FTVwp 

$O.out: $FO $CO $SO $LIBO
	$LD $prereq

y.tab.h squint.c:	squint.y short.y.debug
	yacc -D1 -d squint.y
	mv y.tab.c squint.c
	diff y.debug ref.y.debug
	cp short.y.debug y.debug

ydefs.h:Q:	y.tab.h
	cmp -s y.tab.h ydefs.h || cp y.tab.h ydefs.h

%.$O:	%.c
	$CC $CFLAGS $stem.c
%.$O:	%.s
	$AS $stem.s

bltin.[$O]:R:		comm.h inst.h store.h node.h symbol.h
compile.[$O]:R:	comm.h inst.h node.h symbol.h ydefs.h store.h errjmp.h
const.[$O]:R:		store.h node.h symbol.h ydefs.h errjmp.h
declare.[$O]:R:	store.h node.h symbol.h ydefs.h
error.[$O]:R:		store.h node.h nodenames.h symbol.h typenames.h errjmp.h  ydefs.h
lex.[$O]:R:		store.h node.h symbol.h ydefs.h
main.[$O]:R:		errjmp.h
node.[$O]:R:		store.h node.h symbol.h ydefs.h
squint.[$O]:R:		store.h node.h symbol.h ydefs.h
symbol.[$O]:R:		store.h node.h symbol.h ydefs.h
type.[$O]:R:		store.h node.h symbol.h ydefs.h  store.h errjmp.h
xec.[$O]:R:		store.h node.h inst.h insttab.h comm.h errjmp.h
bltin.[$O]:R:		comm.h inst.h node.h symbol.h store.h slib.h

libg.[$O]:R:	slibgfns.h space.h
space.[$O]:R:	slibgfns.h space.h
fmount.[$O]:R:	slibgfns.h space.h

$FO:	fns.h
$CO:	comm.h store.h
$LIBO:	comm.h store.h libargs.h

#slib.h:V:	sliblib.h slibio.h slibg.h sliblayer.h
slib.h:V:	sliblib.h slibio.h
	cat $prereq > slib.h


nodenames.h typenames.h:	node.h enumtoname
	enumtoname Ntype < node.h > nodenames.h
	enumtoname Ttype < node.h > typenames.h

inst.h insttab.h:Q:	inst
	echo build inst.h insttab.h
	{echo 'typedef enum Inst{'
		sed 's/.*/	&,/' inst;
		echo '	NInst';
	echo '}Inst;'
	sed 's/^I/extern int i/;s/$/\(Proc*\);/' inst
	echo 'extern struct Insttab{ int (*fp)(Proc*); char *name;} insttab[];'} > inst.h
	{sed 's/^I/i/;s/.*/extern int &(Proc*);/' inst;
	echo 'struct Insttab insttab[]={'
	sed 's/.(.*)/	i\1, "&",/' inst
	echo '};'} > insttab.h
	
inst:Q:	$CODE
	cat $CODE | grep '^i.*(Proc \*proc)' | sed 's/^i/I/; s/\(.*//; s/.*/&/' | sort > ninst
	cmp -s inst ninst || mv ninst inst

regress:	squint
	regress
	touch regress
clean:
	rm -f [$OS].out *.[$OS]

install:	$O.out
	# regress
	cp $O.out $home/bin/$objtype/squint
