function M = compute_metrics(t, y, r)
t = t(:);
y = y(:);

if isscalar(r)
    rVec = r * ones(size(y));
else
    rVec = r(:);
end

e = rVec - y;
ePct = 100 * e / max(abs(rVec(end)), eps);

M = struct();
M.finalValue = y(end);
M.ssError = e(end);
M.maxOvershootPct = max(0, 100*(max(y)-rVec(end))/max(abs(rVec(end)),eps));
M.maxUndershootPct = max(0, 100*(rVec(end)-min(y))/max(abs(rVec(end)),eps));
M.IAE = trapz(t, abs(e));
M.ISE = trapz(t, e.^2);

M.tSettle1Pct   = localSettlingTime(t, ePct, 1.0);
M.tSettle075Pct = localSettlingTime(t, ePct, 0.75);
M.tSettle025Pct = localSettlingTime(t, ePct, 0.25);

M.firstHit1Pct   = localFirstHit(t, ePct, 1.0);
M.firstHit075Pct = localFirstHit(t, ePct, 0.75);
M.firstHit025Pct = localFirstHit(t, ePct, 0.25);
end

function ts = localSettlingTime(t, ePct, band)
ts = NaN;
for k = 1:numel(t)
    if all(abs(ePct(k:end)) <= band)
        ts = t(k);
        return;
    end
end
end

function th = localFirstHit(t, ePct, band)
idx = find(abs(ePct) <= band, 1, 'first');
if isempty(idx)
    th = NaN;
else
    th = t(idx);
end
end