// Usage: magma -b label:={1} GetGHyperellipticModel.m >> stdout/{1} 2>&1

load "hyperelliptic/load.m";
load "hyperelliptic/code.m";
SetColumns(0);
if assigned verbose or assigned debug then
    SetVerbose("User1", 1);
end if;
if assigned debug then
    SetDebugOnError(true);
end if;
g := StringToInteger(Split(label, ".")[3]);
if not assigned prec then
    prec := 100;
else
    prec := StringToInteger(prec);
end if;
if g lt 3 then
    label cat ":genus too small";
    exit;
end if;
t0 := ReportStart(label, "hyperelliptic model");
C := HyperellipticModelFromLabel(label : prec:=prec);
ReportEnd(label, "hyperelliptic model", t0);
Write("ghyp_models/" * label, StripWhiteSpace(Sprint(DefiningEquations(C))));
exit;
