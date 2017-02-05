#!/usr/bin/perl -w
use strict;
use warnings;

use Tie::File;

my $i;
my $FileName;
my @LineArray;
my @MAPeriod = (5, 10);
my @Percent = (1, 0);
my $TOTAL_RATIO;
my $TOTAL_PROFIT;

$FileName = "profit.txt";
print("Generate $FileName\n");

tie @LineArray, 'Tie::File', $FileName or die "Unable tie array to $FileName";
@LineArray = ();

push(@LineArray, "TRUE:=1;");
push(@LineArray, "FALSE:=0;");
push(@LineArray, "\r");

push(@LineArray, "MONEY:=10000;");
push(@LineArray, "\r");

push(@LineArray, "FEE:=2/1000;");
push(@LineArray, "\r");

$i = 0;
foreach my $Period (@MAPeriod)
{
    push(@LineArray, "PERCENT_$i:=$Percent[$i];");
    push(@LineArray, "\r");
    
    push(@LineArray, "EMA_PERIOD_$i:=$Period;");
    push(@LineArray, "EXP_MA_$i:=EMA(C,EMA_PERIOD_$i);");    
    push(@LineArray, "\r");
    
    push(@LineArray, "BUY_$i:=(REF(EXP_MA_$i,2)>REF(EXP_MA_$i,1)) AND (EXP_MA_$i>REF(EXP_MA_$i,1));");
    push(@LineArray, "SELL_$i:=(REF(EXP_MA_$i,2)<REF(EXP_MA_$i,1)) AND (EXP_MA_$i<REF(EXP_MA_$i,1));");
    push(@LineArray, "HOLD_$i:=EXP_MA_$i>REF(EXP_MA_$i,1);");
    push(@LineArray, "\r");
    
    push(@LineArray, "RATIO_$i:=IF(HOLD_$i=TRUE,PERCENT_$i,0);");
    push(@LineArray, "MONEY_BUY_$i:=MONEY*RATIO_$i*(1-FEE);");
    push(@LineArray, "\r");
    
    push(@LineArray, "PRICE_$i:=REF(C,BARSLAST(HOLD_$i=FALSE)-1);");
    push(@LineArray, "VOLUME_$i:=INTPART(MONEY_BUY_$i/PRICE_$i/100)*100;");
    push(@LineArray, "VALUE_$i:=VOLUME_$i*C;");
    push(@LineArray, "\r");
    
    push(@LineArray, "BUY_VOLUME_$i:=IF(BUY_$i=TRUE,VOLUME_$i,0);");
    push(@LineArray, "SELL_VOLUME_$i:=IF(SELL_$i=TRUE,REF(VOLUME_$i,1),0);");
    push(@LineArray, "PROFIT_VOLUME_$i:=VOLUME_$i-BUY_VOLUME_$i; {+SELL_VOLUME_$i;}");
    push(@LineArray, "\r");

    push(@LineArray, "PROFIT_$i:=PROFIT_VOLUME_$i*(C-PRICE_$i)*100/MONEY;");
    push(@LineArray, "SUM_PROFIT_$i:=SUM(PROFIT_VOLUME_$i*(C-REF(C,1)),0);");
    push(@LineArray, "\r");
    
    push(@LineArray, "RATIO$i:RATIO_$i;");
    push(@LineArray, "PROFIT$i:PROFIT_VOLUME_$i*(C-PRICE_$i)*100/MONEY;");
    push(@LineArray, "SUM_PROFIT$i:SUM_PROFIT_$i/MONEY;");
    push(@LineArray, "{---------------------------------------------------------------------------------------};");
    push(@LineArray, "\r");
    
    if ($i == 0) {
        $TOTAL_RATIO .= "RATIO_$i";
        $TOTAL_PROFIT .= "SUM_PROFIT_$i";
    } else {
        $TOTAL_RATIO .= "+RATIO_$i";
        $TOTAL_PROFIT .= "+SUM_PROFIT_$i";
    }

    $i++;
}

#push(@LineArray, "TOTAL_RATIO:$TOTAL_RATIO;");
#push(@LineArray, "TOTAL_PROFIT:($TOTAL_PROFIT)/MONEY;");

untie @LineArray;