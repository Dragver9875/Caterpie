function G = compute_margins(L)
% L is open-loop transfer function / ss / zpk object

G = struct();
try
    [Gm,Pm,Wcg,Wcp] = margin(L);
    G.gainMargin    = Gm;
    G.phaseMargin   = Pm;
    G.wGainCross    = Wcg;
    G.wPhaseCross   = Wcp;
    G.bandwidth     = bandwidth(feedback(L,1));
catch ME
    warning('compute_margins failed: %s', ME.message);
    G.gainMargin  = NaN;
    G.phaseMargin = NaN;
    G.wGainCross  = NaN;
    G.wPhaseCross = NaN;
    G.bandwidth   = NaN;
end
end