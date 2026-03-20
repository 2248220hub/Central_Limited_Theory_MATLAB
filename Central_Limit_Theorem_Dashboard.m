
%%   CENTRAL LIMIT THEOREM — Interactive Proof by Simulation
%%   AUTHOR : VINOTH EMBERUMAL - 2248220
%%   Course  :  Space Missions and Systems
%%   Program :  MSc Space and Astronautical Engineering
%%   University: Sapienza Università di Roma  —  A.Y. 2025–2026
%%
%%   Primary Reference:
%%     Tapley, B.D., Schutz, B.E., Born, G.H. (2004).
%%     Statistical Orbit Determination. Elsevier Academic Press.
%%     Appendix A  — Probability and Statistics (pp. 439–471)
%%     §A.8.2      — Gaussian / Normal Distribution (p. 450)
%%     §A.20       — The Central Limit Theorem     (p. 465)
%%
%%   Terminology Note:
%%     Throughout this code, Monte-Carlo results are labelled "Observed"
%%     and analytical results are labelled "Computed".  This mirrors the
%%     standard Orbit Determination convention introduced in TSB §1.2.3
%%     (p. 4, eq. 1.2.8):
%%
%%         Residual  =  (O − C)  =  Observed − Computed
%%
%%     Earlier drafts used "Empirical" and "Theoretical"; those terms have
%%     been replaced in every string, label, and annotation below so that
%%     the vocabulary is consistent with the OD textbook and course.
%%
%%   How to run:
%%     Save this file as  CLT_Demo_Sapienza.m  then type:
%%         >> CLT_Demo_Sapienza
%%     in the MATLAB Command Window.
%%
%%   Layout:
%%     Left   column  :  Theorem box  |  Parent distribution  |  Rule chart
%%     Centre column  :  Main CLT histogram  |  O-C statistics panel
%%     Right  panel   :  All interactive controls
%%                        (each parameter has a slider + keyboard edit box)
%%
%%   Controls (right panel):
%%     n   — number of i.i.d. random variables summed   (1 → 100)
%%     N   — number of Monte-Carlo samples              (100 → 50 000)
%%     a   — lower bound of U(a,b)                      (−5 → 0)
%%     b   — upper bound of U(a,b)                      (0.1 → 5)
%%     ☑   — toggle ±σ probability bands
%%
%%   Theorem  (Lindeberg-Lévy, TSB §A.20):
%%     Z_n = (S_n − n·μ) / (√n · σ)  →  N(0,1)  as  n → ∞
%%     Assumptions:
%%       (A1) Independent
%%       (A2) Identically distributed
%%       (A3) Finite mean  μ = E[X]
%%       (A4) Finite variance  0 < σ² = Var[X] < ∞
%%     For U(a,b):  μ = (a+b)/2,   σ² = (b−a)²/12
%%
%%   68 – 95 – 99.7 % Rule  (TSB §A.8.2, p. 452):
%%     P(|Z| ≤ 1σ) = 68.27 %
%%     P(|Z| ≤ 2σ) = 95.45 %
%%     P(|Z| ≤ 3σ) = 99.73 %
%%
%% =========================================================================

function CLT_Demo_Sapienza()

%% ── SECTION 1 :  COLOUR PALETTE  ─────────────────────────────────────────
%%    All colours defined once here so the figure has a consistent style.

C.hist_face = [0.65 0.80 0.95];   % sky-blue  — histogram bars
C.hist_edge = [0.28 0.48 0.76];   % dark-blue — histogram edge
C.bell      = [0.93 0.30 0.26];   % coral-red — N(0,1) computed curve
C.band1     = [0.98 0.94 0.74];   % pale gold — ±1σ band
C.band2     = [0.88 0.96 0.82];   % pale green— ±2σ band
C.band3     = [0.88 0.88 0.96];   % pale lilac— ±3σ band
C.text      = [0.16 0.16 0.20];   % near-black— body text
C.grid      = [0.86 0.86 0.90];   % light grey— axes grid
C.bg        = [0.97 0.97 0.99];   % off-white — axes background
C.tcol      = [0.18 0.30 0.56];   % deep blue — titles / headings
C.panel_bg  = [0.93 0.94 0.98];   % soft blue — right control panel
C.edit_bg   = [1.00 1.00 1.00];   % pure white— edit-box background
C.red_val   = [0.72 0.10 0.08];   % dark red  — value text in edit box
C.sep       = [0.78 0.82 0.92];   % mid-blue  — separator lines


%% ── SECTION 2 :  FIGURE WINDOW  ──────────────────────────────────────────
%%    Create the main window and the blue title banner.

fig = figure( ...
    'Name',        'CLT Demo — Sapienza',   ...
    'NumberTitle', 'off',                   ...
    'Color',       C.bg,                    ...
    'Units',       'normalized',            ...
    'Position',    [0.01  0.03  0.97  0.92],...
    'Resize',      'on' );

%  Full-width banner at top
annotation(fig, 'rectangle', [0  0.945  1  0.055], ...
    'FaceColor', C.tcol, 'EdgeColor', 'none');

annotation(fig, 'textbox', [0  0.945  1  0.055], ...
    'String',              ['Central Limit Theorem  |  ' ...
                            'Proof by Simulation  |  '   ...
                            'Uniform Distribution'],     ...
    'Color',               'white',                      ...
    'FontSize',            14,                           ...
    'FontWeight',          'bold',                       ...
    'HorizontalAlignment', 'center',                     ...
    'VerticalAlignment',   'middle',                     ...
    'EdgeColor',           'none',                       ...
    'BackgroundColor',     'none' );


%% ── SECTION 3 :  AXES (left and centre columns)  ─────────────────────────
%%    Three axes on the left, two in the centre.
%%    Right column is reserved for the control panel (Section 5).

%  Left column
ax_formula = axes('Parent', fig,                        ...
                  'Position', [0.04  0.67  0.33  0.25], ...
                  'Visible', 'off');                     %  theorem text box

ax_parent  = axes('Parent', fig,                        ...
                  'Position', [0.04  0.39  0.33  0.24], ...
                  'Color', C.bg);                        %  U(a,b) histogram

ax_rule    = axes('Parent', fig,                        ...
                  'Position', [0.04  0.04  0.33  0.29], ...
                  'Color', C.bg);                        %  68-95-99.7% bars

%  Centre column
ax_main    = axes('Parent', fig,                        ...
                  'Position', [0.37  0.30  0.40  0.60], ...
                  'Color', C.bg);                        %  main CLT plot

ax_stats   = axes('Parent', fig,                        ...
                  'Position', [0.37  0.04  0.40  0.22], ...
                  'Visible', 'off');                     %  O-C stats panel


%% ── SECTION 4 :  RIGHT CONTROL PANEL  ────────────────────────────────────
%%    All four parameters (n, N, a, b) share the same row layout:
%%      [Label]  [──── Slider ────]  [ Edit ]
%%                min hint  max hint
%%    The edit box accepts typed values; pressing Enter applies the value
%%    (clamped to the slider range).  Invalid input is silently ignored.

rp = uipanel( ...
    'Parent',          fig,            ...
    'Units',           'normalized',   ...
    'Position',        [0.79  0.05  0.20  0.88], ...
    'BackgroundColor', C.panel_bg,     ...
    'BorderType',      'line',         ...
    'HighlightColor',  C.tcol,         ...
    'Title',           ' Controls',    ...
    'ForegroundColor', C.tcol,         ...
    'FontSize',        10,             ...
    'FontWeight',      'bold' );

% ── inner helper : build one labelled row ─────────────────────────────────
%   ybase  = bottom of the row in panel-normalised coordinates
%   Returns [slider_handle, editbox_handle]
    function [sl_h, ed_h] = make_row(label_str, ybase, mn, mx, init, fmt)

        % Parameter label
        uicontrol(rp,                                    ...
            'Style',               'text',               ...
            'String',              label_str,            ...
            'Units',               'normalized',          ...
            'Position',            [0.04  ybase+0.054  0.92  0.046], ...
            'BackgroundColor',     C.panel_bg,           ...
            'ForegroundColor',     C.tcol,               ...
            'FontSize',            9.5,                  ...
            'FontWeight',          'bold',               ...
            'HorizontalAlignment', 'left' );

        % Slider (60 % of panel width)
        sl_h = uicontrol(rp,                             ...
            'Style',    'slider',                         ...
            'Min',      mn,                              ...
            'Max',      mx,                              ...
            'Value',    init,                            ...
            'Units',    'normalized',                     ...
            'Position', [0.04  ybase+0.004  0.60  0.046],...
            'BackgroundColor', [0.82  0.88  0.96],       ...
            'SliderStep', [1/(mx-mn+1e-9), 10/(mx-mn+1e-9)] );

        % Edit box (30 % of panel width, white background)
        ed_h = uicontrol(rp,                             ...
            'Style',               'edit',               ...
            'String',              num2str(init, fmt),   ...
            'Units',               'normalized',          ...
            'Position',            [0.66  ybase+0.004  0.30  0.046], ...
            'BackgroundColor',     C.edit_bg,            ...
            'ForegroundColor',     C.red_val,            ...
            'FontSize',            9.5,                  ...
            'FontWeight',          'bold',               ...
            'HorizontalAlignment', 'center' );

        % Min / max hint labels (small, below slider)
        uicontrol(rp, 'Style','text',                    ...
            'String',              num2str(mn),          ...
            'Units',               'normalized',          ...
            'Position',            [0.04  ybase-0.012  0.12  0.030], ...
            'BackgroundColor',     C.panel_bg,           ...
            'ForegroundColor',     [0.55  0.55  0.60],  ...
            'FontSize',            7.5,                  ...
            'HorizontalAlignment', 'left' );

        uicontrol(rp, 'Style','text',                    ...
            'String',              num2str(mx),          ...
            'Units',               'normalized',          ...
            'Position',            [0.52  ybase-0.012  0.12  0.030], ...
            'BackgroundColor',     C.panel_bg,           ...
            'ForegroundColor',     [0.55  0.55  0.60],  ...
            'FontSize',            7.5,                  ...
            'HorizontalAlignment', 'right' );
    end
% ── end helper ────────────────────────────────────────────────────────────

%  Row definitions  [label, y-base, min, max, initial, format]
rows_def = {
    'n   (# RVs summed)',  0.84,    1,    100,    1,    '%d';
    'N   (MC samples)',    0.72,  100,  50000, 5000,    '%d';
    'a   (lower bound)',   0.60,   -5,      0,    0,  '%.2f';
    'b   (upper bound)',   0.48,  0.1,      5,    1,  '%.2f';
};

sl = gobjects(1, 4);
ed = gobjects(1, 4);

for k = 1:4
    [sl(k), ed(k)] = make_row( ...
        rows_def{k,1}, rows_def{k,2}, rows_def{k,3}, ...
        rows_def{k,4}, rows_def{k,5}, rows_def{k,6} );
end

%  Separator line between sliders and checkbox
annotation(fig, 'line', [0.790  0.990], [0.352  0.352], ...
    'Color', C.sep, 'LineWidth', 1.2);

%  Sigma-bands toggle checkbox
chk = uicontrol(rp,                                      ...
    'Style',           'checkbox',                        ...
    'String',          'Show  ± σ sigma  bands',            ...
    'Value',           1,                                 ...
    'Units',           'normalized',                      ...
    'Position',        [0.05  0.36  0.90  0.045],         ...
    'BackgroundColor', C.panel_bg,                        ...
    'ForegroundColor', C.tcol,                            ...
    'FontSize',        9.5,                               ...
    'FontWeight',      'bold' );

%  Professor demo hint card
uicontrol(rp, 'Style','text',                                      ...
    'String',  sprintf(['--- Iterations to Validate ---\n\n'        ...
                        '1: n=1,  N=5000 a=0, b=1\n'                             ...
                        '   flat uniform, no CLT\n\n'               ...
                        '2: n=3,  N=5000\n'                         ...
                        '   a=0, b=1 triangular, CLT starting\n\n'           ...
                        '3: n=10, N=5000 a=0, b=1\n'                             ...
                        '   bell visible, CLT working\n\n'          ...
                        '4: n=30, N=5000 a=0, b=1\n'                             ...
                        '   overlaps N(0,1), CLT proved\n\n'        ...
                        '5: n=30, N=5000 a=-3, b=2\n'                            ...
                        '   CLT holds any U(a,b)']),                ...
    'Units',               'normalized',                            ...
    'Position',            [0.04  0.010  0.92  0.32],                ...
    'BackgroundColor',     [0.90  0.92  0.97],                      ...
    'ForegroundColor',     C.tcol,                                  ...
    'FontSize',            8.0,                                     ...
    'FontWeight',          'bold',                                  ...
    'HorizontalAlignment', 'left' );

%  Usage instructions


%% ── SECTION 5 :  NESTED UPDATE FUNCTION  ─────────────────────────────────
%%    Called every time any slider moves or any edit box is confirmed.
%%    Reads the four parameter values, runs the Monte-Carlo simulation,
%%    and redraws all five panels.

    function update(~, ~)

        % ── 5.1  Read current parameter values ───────────────────────
        n_val = round( get(sl(1), 'Value') );
        N_val = round( get(sl(2), 'Value') );
        a_val =        get(sl(3), 'Value');
        b_val =        get(sl(4), 'Value');

        %  Guard: ensure b > a
        if b_val <= a_val + 0.05
            b_val = a_val + 0.05;
            set(sl(4), 'Value', b_val);
        end

        %  Sync all edit boxes to slider values
        set(ed(1), 'String', num2str(n_val));
        set(ed(2), 'String', num2str(N_val));
        set(ed(3), 'String', sprintf('%.2f', a_val));
        set(ed(4), 'String', sprintf('%.2f', b_val));

        show_bands = logical( get(chk, 'Value') );

        % ── 5.2  Analytical (Computed) parameters  (TSB §A.8.1) ──────
        mu_X   = (a_val + b_val) / 2;          %  E[X]      = (a+b)/2
        var_X  = (b_val - a_val)^2 / 12;       %  Var[X]    = (b-a)²/12
        sig_X  = sqrt(var_X);                   %  σ[X]
        mu_Sn  = n_val * mu_X;                  %  E[S_n]    = n·μ
        sig_Sn = sqrt(n_val) * sig_X;           %  σ[S_n]    = √n·σ

        % ── 5.3  Monte-Carlo simulation  (Observed results) ──────────
        %   Each row of X_mat is one realisation of (X_1,...,X_n)
        X_mat = a_val + (b_val - a_val) * rand(N_val, n_val);
        S_n   = sum(X_mat, 2);                  %  S_n = ΣX_i
        Z_n   = (S_n - mu_Sn) / (sig_Sn + 1e-12);  %  standardise

        %  Observed percentages inside 1σ, 2σ, 3σ bands
        p1 = mean(abs(Z_n) <= 1) * 100;
        p2 = mean(abs(Z_n) <= 2) * 100;
        p3 = mean(abs(Z_n) <= 3) * 100;


        % ═══════════════════════════════════════════════════════════
        % PANEL A :  THEOREM BOX  (top-left, ax_formula)
        % ═══════════════════════════════════════════════════════════
        axes(ax_formula); cla; axis off; %#ok<LAXES>

        dy = 0.132;   %  vertical step between text lines

        text(0, 1.00, 'THEOREM  (Lindeberg-Lévy CLT)', ...
            'FontSize',11, 'FontWeight','bold', 'Color',C.tcol, ...
            'Interpreter','none');

        text(0, 1.00-dy, ...
            sprintf('X_i ~ U(%.2f,%.2f),  n=%d,  N=%d', ...
                    a_val, b_val, n_val, N_val), ...
            'FontSize',10, 'Color',C.text, 'Interpreter','none');

        text(0, 1.00-2*dy, ...
            sprintf('E[X] = %.4f      Var[X] = %.4f', mu_X, var_X), ...
            'FontSize',10, 'Color',C.text, 'Interpreter','none');

        text(0, 1.00-3*dy, ...
            sprintf('E[S_n] = %.4f    sigma[S_n] = %.4f', mu_Sn, sig_Sn), ...
            'FontSize',10, 'Color',C.text, 'Interpreter','none');

        text(0, 1.00-4*dy, ...
            'Z_n = (S_n - n*mu)/(sqrt(n)*sigma)  -->  N(0,1)', ...
            'FontSize',10.5, 'FontWeight','bold', ...
            'Color',[0.10 0.32 0.62], 'Interpreter','none');

        text(0, 1.00-5*dy, 'Assumptions:', ...
            'FontSize',9, 'FontWeight','bold', 'Color',C.text, ...
            'Interpreter','none');

        text(0, 1.00-6*dy, ...
            '(A1) Independent     (A2) Identically distributed', ...
            'FontSize',9, 'Color',C.text, 'Interpreter','none');

        text(0, 1.00-7*dy, ...
            '(A3) Finite mean     (A4) 0 < Var[X] < inf', ...
            'FontSize',9, 'Color',C.text, 'Interpreter','none');


        % ═══════════════════════════════════════════════════════════
        % PANEL B :  PARENT DISTRIBUTION  (middle-left, ax_parent)
        % ═══════════════════════════════════════════════════════════
        axes(ax_parent); cla; hold on; %#ok<LAXES>
        set(ax_parent, ...
            'Color',C.bg, 'GridColor',C.grid, 'Box','off', ...
            'FontSize',9,  'XColor',C.text,    'YColor',C.text);

        mg = 0.38 * (b_val - a_val);   %  margin around rectangle

        fill([a_val  a_val  b_val  b_val  a_val], ...
             [0  1/(b_val-a_val)  1/(b_val-a_val)  0  0], ...
             C.band1, 'EdgeColor',C.hist_edge, 'LineWidth',1.5);

        xL = linspace(a_val-mg, b_val+mg, 400);
        fL = (xL >= a_val & xL <= b_val) / (b_val - a_val);
        plot(xL, fL, 'Color',C.hist_edge, 'LineWidth',2.2);

        xlabel('X',    'FontSize',9.5, 'FontWeight','bold', 'Color',C.text);
        ylabel('f(x)', 'FontSize',9.5, 'Color',C.text);
        title(sprintf('Parent Distribution: U(%.2f, %.2f)', a_val, b_val), ...
              'FontSize',10, 'FontWeight','bold', 'Color',C.tcol);

        xlim([a_val-mg,  b_val+mg]);
        ylim([0,  1.5/(b_val-a_val)]);
        grid on;  hold off;


        % ═══════════════════════════════════════════════════════════
        % PANEL C :  MAIN CLT HISTOGRAM  (centre, ax_main)
        % ═══════════════════════════════════════════════════════════
        axes(ax_main); cla; hold on;
        set(ax_main, ...
            'Color',C.bg, 'GridColor',C.grid, 'Box','off', ...
            'FontSize',10, 'XColor',C.text, 'YColor',C.text);

        %  Shaded σ bands (drawn first so bars appear on top)
        if show_bands
            fill([-3 -3  3  3], [0  0.42  0.42  0], C.band3, 'EdgeColor','none');
            fill([-2 -2  2  2], [0  0.42  0.42  0], C.band2, 'EdgeColor','none');
            fill([-1 -1  1  1], [0  0.42  0.42  0], C.band1, 'EdgeColor','none');
        end

        %  Observed Z_n histogram
        nb    = max(25, min(80, round(2 * N_val^(1/3))));
        [cts, edg] = histcounts(Z_n, nb, 'Normalization','pdf');
        ctrs  = (edg(1:end-1) + edg(2:end)) / 2;
        bar(ctrs, cts, 1.0, ...
            'FaceColor', C.hist_face, 'EdgeColor', C.hist_edge, ...
            'LineWidth', 0.7, 'FaceAlpha', 0.88);

        %  Computed N(0,1) curve  (TSB §A.8.2, eq. A.8.7)
        zr  = linspace(-4.5, 4.5, 600);
        phi = exp(-0.5 * zr.^2) / sqrt(2*pi);
        plot(zr, phi, 'Color',C.bell, 'LineWidth',4.0);

        %  Vertical dashed lines at ±1σ, ±2σ, ±3σ
        if show_bands
            for k = [1 2 3]
                xline( k, '--', 'Color',[0.52 0.42 0.10], ...
                    'LineWidth',1.0, 'Alpha',0.75);
                xline(-k, '--', 'Color',[0.52 0.42 0.10], ...
                    'LineWidth',1.0, 'Alpha',0.75);
            end
            text( 0,   0.45, '{\bf\pm1\sigma}: 68.27%', ...
                'FontSize',9, 'Color',[0.50 0.38 0.04], ...
                'HorizontalAlignment','center');
            text( 0,   0.22, '{\bf\pm2\sigma}: 95.45%', ...
                'FontSize',9, 'Color',[0.20 0.50 0.14], ...
                'HorizontalAlignment','center');
            text( 3.3, 0.09, '{\bf\pm3\sigma}: 99.73%', ...
                'FontSize',8.5, 'Color',[0.28 0.24 0.62], ...
                'HorizontalAlignment','center');

            %  NOTE: legend labels use Observed / Computed  (O-C convention,
            %         TSB §1.2.3).  Previous drafts said "simulated / theory".
            legend({'','','','Z_n  (observed)','N(0,1)  (computed)'}, ...
                'Location','northeast', 'FontSize',9.5, ...
                'EdgeColor',C.grid, 'Color',C.bg);
        else
            legend({'Z_n  (observed)','N(0,1)  (computed)'}, ...
                'Location','northeast', 'FontSize',9.5, ...
                'EdgeColor',C.grid, 'Color',C.bg);
        end

        xlabel('Z_n  =  (S_n − n\mu) / (\surd n \cdot \sigma)', ...
            'FontSize',9, 'FontWeight','bold', 'Color',C.text);
        ylabel('Probability Density', 'FontSize',10, 'Color',C.text);
        title(sprintf('CLT Convergence   n = %d,   N = %d samples', ...
                      n_val, N_val), ...
              'FontSize',12, 'FontWeight','bold', 'Color',C.tcol);

        xlim([-4.5  4.5]);
        ylim([0  0.6]);
        grid on;  hold off;


        % ═══════════════════════════════════════════════════════════
        % PANEL D :  O-C STATISTICS  (centre-bottom, ax_stats)
        % ═══════════════════════════════════════════════════════════
        %%  NOTE: Labels say "Observed" (Monte-Carlo) vs "Computed"
        %%        (analytical N(0,1)).  This directly maps to the
        %%        O-C residual framework of TSB §1.2.3.
        axes(ax_stats); cla; axis off; 

        mu_obs = mean(Z_n);
        si_obs = std(Z_n);
        sk_obs = skewness(Z_n);
        kt_obs = kurtosis(Z_n) - 3;   %  excess kurtosis; N(0,1) = 0

        text(0.01, 0.9, 'O-C RESIDUAL STATISTICS  (Standardised Z_n)', ...
            'FontSize',10, 'FontWeight','bold', 'Color',C.tcol, ...
            'Units','normalized');

        %  Table rows: [row-label, value-string]
        %  "Observed" = Monte-Carlo result
        %  "Computed" = analytical value from N(0,1) theory
        stats_rows = {
            'Observed mean   :',  sprintf('%.4f   (computed: 0.0000)', mu_obs);
            'Observed sigma  :',  sprintf('%.4f   (computed: 1.0000)', si_obs);
            'Skewness        :',  sprintf('%.4f   (computed: 0.0000)', sk_obs);
            'Excess kurtosis :',  sprintf('%.4f   (computed: 0.0000)', kt_obs);
        };

        for r = 1:4
            yy = 0.76 - (r-1) * 0.18;
            text(0.01, yy, stats_rows{r,1}, ...
                'FontSize',9.5, 'FontWeight','bold', 'Color',C.text, ...
                'Units','normalized');
            text(0.40, yy, stats_rows{r,2}, ...
                'FontSize',9.5, 'Color',[0.08 0.42 0.18], ...
                'Units','normalized');
        end

        %  Convergence index  (1 = perfect N(0,1))
        ci = max(0, min(1,  1 - abs(mu_obs) - abs(si_obs-1) ));
        text(0.01, 0.06, ...
            sprintf('Convergence index: %.1f%%  (100%% = perfect N(0,1))', ...
                    ci*100), ...
            'FontSize',9.5, 'FontWeight','bold', 'Color',C.tcol, ...
            'Units','normalized');


        % ═══════════════════════════════════════════════════════════
        % PANEL E :  68–95–99.7 % RULE  (bottom-left, ax_rule)
        % ═══════════════════════════════════════════════════════════
        %%  NOTE: "Observed" bars  = Monte-Carlo percentages (red).
        %%        "Computed" bars  = exact N(0,1) theory  (gold).
        %%        Consistent with O-C residual terminology, TSB §1.2.3.
        axes(ax_rule); cla; hold on; 
        set(ax_rule, ...
            'Color',C.bg, 'GridColor',C.grid, 'Box','off', ...
            'FontSize',9.5, 'XColor',C.text, 'YColor',C.text);

        th = [68.27;  95.45;  99.73];   %  computed values
        em = [p1;     p2;     p3   ];   %  observed values

        bh = bar([1 2 3], [th, em], 0.65, 'grouped');

        bh(1).FaceColor = C.band1;          %  gold  — computed
        bh(1).EdgeColor = [0.52 0.42 0.10];
        bh(2).FaceColor = C.bell;           %  red   — observed
        bh(2).FaceAlpha = 0.82;
        bh(2).EdgeColor = [0.62 0.14 0.12];

        set(ax_rule, ...
            'XTick',      [1 2 3], ...
            'XTickLabel', {'{\pm}1\sigma','{\pm}2\sigma','{\pm}3\sigma'});

        ylabel('%', 'FontSize',8, 'Color',C.text);
        title('68–95–99.7% Rule  |  Computed vs Observed', ...
              'FontSize',8, 'FontWeight','bold', 'Color',C.tcol);
        ylim([0  120]);
        grid on;

        %  Percentage annotations above bars
        for k = 1:3
            text(k - 0.17, th(k) + 2, sprintf('%.2f%%', th(k)), ...
                'FontSize',8.5, 'Color',[0.45 0.28 0.04], ...
                'HorizontalAlignment','center');
            text(k + 0.17, em(k) + 2, sprintf('%.1f%%', em(k)), ...
                'FontSize',8.5, 'FontWeight','bold', 'Color',C.bell, ...
                'HorizontalAlignment','center');
        end
        hold off;

    end   %  ── end update() ────────────────────────────────────────────────


%% ── SECTION 6 :  SLIDER CALLBACKS  ───────────────────────────────────────
%%    When a slider moves: push its value into the paired edit box, then
%%    call update() to redraw everything.

    function slider_moved(src_sl, ~, ed_h, fmt)
        val = get(src_sl, 'Value');
        set(ed_h, 'String', num2str(val, fmt));
        update();
    end


%% ── SECTION 7 :  EDIT BOX CALLBACKS  ─────────────────────────────────────
%%    When Enter is pressed in an edit box: parse the typed value, clamp
%%    it to the slider's valid range, push it to the slider, then redraw.

    function edit_entered(src_ed, ~, sl_h, fmt)
        raw = str2double( get(src_ed, 'String') );
        if isnan(raw)                          %  invalid input → restore
            set(src_ed, 'String', num2str(get(sl_h,'Value'), fmt));
            return
        end
        val = max( get(sl_h,'Min'),  min(get(sl_h,'Max'), raw) );
        set(sl_h,  'Value',  val);
        set(src_ed,'String', num2str(val, fmt));
        update();
    end


%% ── SECTION 8 :  ATTACH ALL CALLBACKS  ───────────────────────────────────
%%    Loop over all four parameter rows.
%%    The loop variable is captured correctly using the "kk = k" trick.

fmts = {'%d', '%d', '%.2f', '%.2f'};

for k = 1:4
    kk = k;   %  capture by value for anonymous function closure
    set(sl(k), 'Callback', @(s,e) slider_moved(s, e, ed(kk), fmts{kk}));
    set(ed(k), 'Callback', @(s,e) edit_entered(s, e, sl(kk), fmts{kk}));
end

set(chk, 'Callback', @update);


%% ── SECTION 9 :  INITIAL DRAW  ───────────────────────────────────────────
%%    Trigger a full redraw with the default parameter values.

update();


%% ── SECTION 10 :  COMMAND WINDOW OUTPUT  ─────────────────────────────────
%%    Print a human-readable summary and a 20-row numerical dataset
%%    suitable for inclusion in a professor email or report.

fprintf('\n');
fprintf('=======================================================\n');
fprintf('  CLT DEMO — Sapienza  |  v3 — Right-Panel Controls  \n');
fprintf('  Ref: Tapley, Schutz & Born (2004), Appendix A       \n');
fprintf('  Terminology: Observed (O) / Computed (C), TSB §1.2.3\n');
fprintf('=======================================================\n');
fprintf('  Slider 1 : n  — # i.i.d. RVs summed  (drag or type)\n');
fprintf('  Slider 2 : N  — MC samples            (drag or type)\n');
fprintf('  Slider 3 : a  — lower bound U(a,b)    (drag or type)\n');
fprintf('  Slider 4 : b  — upper bound U(a,b)    (drag or type)\n');
fprintf('  Checkbox :     sigma bands  ON / OFF               \n');
fprintf('-------------------------------------------------------\n');
fprintf('  ITERATION SEQUENCES:\n');
fprintf('  1: n=1,  N=5000, a=0, b=1  → flat uniform,  no CLT        \n');
fprintf('  2: n=3,  N=5000, a=0, b=1  → triangular,    CLT starting  \n');
fprintf('  3: n=10, N=5000, a=0, b=1  → bell visible,  CLT working   \n');
fprintf('  4: n=30, N=5000, a=0, b=1  → overlaps N(0,1), CLT proved  \n');
fprintf('  5: n=30, N=5000, a=-3,b=2  → CLT holds for any U(a,b)     \n');
fprintf('=======================================================\n\n');

%  ── Numerical dataset for professor email ────────────────────────────
fprintf('--- DATASET  (U(0,1), n=30, N=20, seed=42) ---\n');
fprintf('  (Copy into email; paste into Excel or MATLAB)\n\n');
fprintf('%-6s  %-14s  %-12s  %-10s\n', ...
        'Trial', 'Observed Mean', 'Observed S_n', 'Z_n');
fprintf('%s\n', repmat('-', 50, 1));

rng(42);
nd = 30;  Nd = 20;
mu_d  = 0.5;
sig_d = 1 / sqrt(12);

Xd = rand(Nd, nd);
Sd = sum(Xd, 2);
Zd = (Sd - nd*mu_d) / (sqrt(nd) * sig_d);

for i = 1:Nd
    fprintf('%-6d  %-14.4f  %-12.4f  %-10.4f\n', ...
            i, mean(Xd(i,:)), Sd(i), Zd(i));
end

fprintf('%s\n', repmat('-', 50, 1));
fprintf('Computed  : E[Z] = 0.0000   sigma[Z] = 1.0000\n');
fprintf('Observed  : E[Z] = %.4f   sigma[Z] = %.4f\n', ...
        mean(Zd), std(Zd));

end   %  ── end CLT_Demo_Sapienza ─────────────────────────────────────────