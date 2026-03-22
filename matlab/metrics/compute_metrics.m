function M = compute_metrics(t, y, r)
% Basic time-domain metrics relative to constant reference r

t = t(:);
y = y(:);

if numel(r) == 1
    rVec = r * ones(size(y));
else
    rVec = r(:);
end

e = rVec - y;
ePct = 100 * e / max(abs(r), eps);

M = struct();
M.finalValue = y(end);
M.ssError = e(end);
M.maxOvershootPct = max(0, 100*(max(y)-r)/max(abs(r),eps));
M.maxUndershootPct = max(0, 100*(r-min(y))/max(abs(r),eps));
M.IAE = trapz(t, abs(e));
M.ISE = trapz(t, e.^2);

% settling times
idx1 = find(abs(ePct) <= 1, 1, 'first');
idx075 = find(abs(ePct) <= 0.75, 1, 'first');
idx025 = find(abs(ePct) <= 0.25, 1, 'first');

M.tSettle1Pct   = localSettlingTime(t, ePct, 1.0);
M.tSettle075Pct = localSettlingTime(t, ePct, 0.75);
M.tSettle025Pct = localSettlingTime(t, ePct, 0.25);

M.firstHit1Pct   = iff(isempty(idx1), NaN, t(idx1));
M.firstHit075Pct = iff(isempty(idx075), NaN, t(idx075));
M.firstHit025Pct = iff(isempty(idx025), NaN, t(idx025));
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

function out = iff(cond, a, b)
if cond
    out = a;
else
    out = b;
end
end