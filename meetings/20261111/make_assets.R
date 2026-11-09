# Figures and table snippets for meetings/20261111.qmd and meetings/20261111/supplementary.qmd.
# Reads the result tables that `Rscript scripts/run_all.R` and `scripts/run_perturbation.R` write in the
# private repository paper1_gps_network_choice (gitignored there). The pages stay static: CI has no R,
# so this script runs on my Mac and its output is committed.
#
#   Rscript meetings/20261111/make_assets.R
#
# REPORT_DIR overrides the input folder, ASSET_OUT overrides the output folder (used for testing).
suppressPackageStartupMessages(library(data.table))

here <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])))
rep_dir <- Sys.getenv("REPORT_DIR", path.expand("~/01_phd/paper1_gps_network_choice/data/synthetic/report"))
out <- Sys.getenv("ASSET_OUT", here)
fig_dir <- file.path(out, "figures"); tab_dir <- file.path(out, "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE); dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

rd <- function(f) { p <- file.path(rep_dir, f); if (file.exists(p)) fread(p) else NULL }
scores <- rd("scores.csv"); best_cell <- rd("best_cells.csv"); est <- rd("estimation.csv"); nul <- rd("null_case.csv")
est_t <- rd("estimation_times.csv"); cost_cells <- rd("cost_cells.csv")
perturb <- rd("perturb.csv"); cells_pr <- rd("perturb_cells_pr.csv")
stopifnot(!is.null(scores), !is.null(best_cell), !is.null(est), !is.null(nul))

f3 <- function(v) ifelse(is.na(v), "NA", sprintf("%.3f", v))
# Tables from before S6 lack the LR columns; add them as NA so the script still runs on old tables.
with_lr <- function(x) {
  if (!is.null(x)) for (cc in setdiff(c("lr_coverage", "lr_excludes_0", "oob_share"), names(x))) x[, (cc) := NA_real_]
  x
}
est <- with_lr(est); nul <- with_lr(nul)
# The row "none" is the model without a social effect; "true" is the true W.
est <- est[W != "none"][W == "true", W := "true W"]; nul <- nul[W != "none"][W == "true", W := "true W"]
write_tab <- function(df, name) {
  writeLines(knitr::kable(df, format = "pipe", align = "l"), file.path(tab_dir, name))
}
png_open <- function(name, w, h) png(file.path(fig_dir, name), width = w, height = h, res = 160, bg = "white")

pair_col <- c(friend = "#1b7f79", friend_coworker = "#f2cc8f", coworker = "#e76f51", other = "grey85")

## Figure 1: who fills the top k of each method (port of chunk fig-cow of the benchmark report)
show <- c("NAIVE_count", "R1a_total", "R1b_minutes", "R1b_days", "R2_WO", "R2_WL", "R2_TD_t60_q05",
          "R2d_D_q0.1_tau30", "R2d_F", "R2e_G", "R3a_logp", "R3b_logp", "R3c_logp",
          "R1b_minutes_nofoci", "R3a_logp_nofoci", "R3b_logp_nofoci", "R3c_logp_nofoci", best_cell$method)
fig <- scores[method %in% show][!duplicated(method)][order(auc)]
sh <- t(as.matrix(fig[, .(share_friend, share_friend_coworker, share_coworker, share_other)]))
png_open("coworker_trap.png", 1500, 1000)
op <- par(mar = c(4.2, 13.5, 3.6, 6.5), xpd = NA)
bp <- barplot(sh, horiz = TRUE, names.arg = fig$method, las = 1, cex.names = 0.8, border = NA,
              col = pair_col, xlab = "share of the 225 top-ranked pairs")
text(1.02, bp, sprintf("AUC %.3f", fig$auc), adj = 0, cex = 0.75)
legend("top", inset = c(0, -0.09), horiz = TRUE, legend = c("friend", "friend_coworker", "coworker", "other"),
       fill = pair_col, border = NA, bty = "n", cex = 0.85)
par(op); dev.off()

## Figure 2: bias of gamma-hat at gamma = 0.5 by network (port of chunk fig-bias)
b <- est[order(bias)]
png_open("bias_by_network.png", 1400, 760)
op <- par(mar = c(4.4, 17, 1.5, 1.5))
y <- seq_len(nrow(b))
plot(b$bias, y, xlim = range(c(b$bias - 2 * b$mc_se, b$bias + 2 * b$mc_se, 0)), yaxt = "n", pch = 19, cex = 1.3,
     ylab = "", xlab = "bias of gamma-hat (true gamma = 0.5)", col = "#1b6ca8")
segments(b$bias - 2 * b$mc_se, y, b$bias + 2 * b$mc_se, y, col = "#1b6ca8", lwd = 2)
abline(v = 0, lty = 2, col = "grey40")
axis(2, at = y, labels = b$W, las = 1, cex.axis = 0.85)
par(op); dev.off()

## Tables
# Best method of each rung by AUC (port of chunk tab-rung)
pl <- scores[cell %in% c("C00", "C10") & !grepl("_nofoci", method)]
br <- pl[order(-auc, method)][, .SD[1], by = rung][order(rung)]
write_tab(br[, .(rung, method, AUC = f3(auc), `P@k` = f3(precision_at_k), friend = f3(share_friend),
                 coworker = f3(share_coworker))], "_best_rung.md")

# Page 1, table A: naive count, one count method, best method of each cell
pick <- rbind(scores[method %in% c("NAIVE_count", "R1b_minutes")][!duplicated(method)][, .(method, cell)],
              best_cell[order(cell), .(method, cell)])
rec <- merge(pick, scores[!duplicated(paste(method, cell))], by = c("method", "cell"), sort = FALSE)
write_tab(rec[, .(method, cell, AUC = f3(auc), `P@k` = f3(precision_at_k), `friend share` = f3(share_friend),
                  `coworker share` = f3(share_coworker))], "_recovery_main.md")

# Gamma-hat by network at gamma = 0.5
write_tab(est[, .(network = W, `mean gamma-hat` = f3(mean_gamma_hat), sd = f3(sd_gamma_hat), bias = f3(bias),
                  `MC s.e.` = f3(mc_se), `Wald coverage` = f3(coverage), `LR coverage` = f3(lr_coverage),
                  `out-of-bound share` = f3(oob_share), `converged share` = f3(converged_share))], "_est.md")

# Null case: true gamma = 0
write_tab(nul[, .(network = W, `mean gamma-hat` = f3(mean_gamma_hat), sd = f3(sd_gamma_hat),
                  `Wald rejects 0` = f3(excludes_0), `LR rejects 0` = f3(lr_excludes_0),
                  `median s.e.` = f3(median_se), `out-of-bound share` = f3(oob_share),
                  `converged share` = f3(converged_share))], "_null.md")

# Four cells on the main city (port of chunk tab-cells-main)
m <- copy(best_cell)[, W := sprintf("%s: %s", cell, method)]
m <- est[, .(W, bias, mc_se, coverage, lr_coverage, oob_share)][m, on = "W"]
m <- nul[, .(W, reject_0 = excludes_0, lr_excludes_0)][m, on = "W"]
m <- est_t[, .(W, fit_median_s)][m, on = "W"]
m <- cost_cells[, .(cell, build_s, n_methods)][m, on = "cell"]
write_tab(m[order(cell), .(cell, AUC = f3(auc), `P@k` = f3(precision_at_k), coworker = f3(share_coworker),
                           fc_recall = f3(fc_recall_at_k), bias = f3(bias), `Wald coverage` = f3(coverage),
                           `LR coverage` = f3(lr_coverage), `Wald rejects 0` = f3(reject_0),
                           `LR rejects 0` = f3(lr_excludes_0), `out-of-bound share` = f3(oob_share),
                           methods = n_methods, build_s = sprintf("%.1f", build_s),
                           fit_median_s = sprintf("%.2f", fit_median_s))], "_cells_main.md")

## S8: perturbed true W (needs perturb.csv from scripts/run_perturbation.R)
if (!is.null(perturb) && !is.null(cells_pr)) {
  g5 <- perturb[gamma == 0.5]; g0 <- perturb[gamma == 0]
  write_tab(g5[g0[, .(spec, lr0 = lr_excludes_0, wald0 = wald_excludes_0, oob0 = oob_share)], on = "spec"][
    , .(spec, r, p, source = fp_source, bias = f3(bias), `MC s.e.` = f3(mc_se), converged = f3(converged_share),
        `LR coverage` = f3(lr_coverage), `Wald coverage` = f3(wald_coverage), `out-of-bound` = f3(oob_share),
        `LR rejects 0 (gamma 0)` = f3(lr0), `Wald rejects 0 (gamma 0)` = f3(wald0))], "_s8.md")
  write_tab(cells_pr[, .(cell, method, n_edges, precision = f3(precision), recall = f3(recall), fc_kept = f3(fc_kept))],
            "_s8_cells.md")

  # Figure 3: bias against recall r, one line per precision p, one panel per false-tie source.
  # The four cells of Result 1 enter at their recall with their own bias at gamma = 0.5 (precision 0.3).
  cellb <- merge(est[grepl("^C[01]{2}:", W), .(cell = sub(":.*$", "", W), bias, mc_se)],
                 cells_pr[, .(cell, precision, recall)], by = "cell")
  pcol <- c("1" = "#1b6ca8", "0.8" = "#e8a33d", "0.6" = "#7a2e0e"); ppch <- c("1" = 16, "0.8" = 17, "0.6" = 15)
  yl <- range(c(g5$bias - 2 * g5$mc_se, g5$bias + 2 * g5$mc_se, cellb$bias - 2 * cellb$mc_se, 0))
  png_open("s8_map.png", 1500, 800)
  op <- par(mfrow = c(1, 2), mar = c(4.4, 4.4, 3, 1), oma = c(0, 0, 0, 0))
  for (src in c("random", "coworker")) {
    plot(NA, xlim = c(0.56, 1.04), ylim = yl, xlab = "recall r of W (share of true ties kept)",
         ylab = "bias of gamma-hat (true gamma = 0.5)", main = sprintf("false ties from: %s", src))
    abline(h = 0, lty = 2, col = "grey40")
    for (pp in c(1, 0.8, 0.6)) {
      d <- g5[p == pp & (fp_source == src | fp_source == "none")][order(r)]
      x <- d$r + c("1" = -0.008, "0.8" = 0, "0.6" = 0.008)[as.character(pp)]
      segments(x, d$bias - 2 * d$mc_se, x, d$bias + 2 * d$mc_se, col = pcol[as.character(pp)], lwd = 1.5)
      lines(x, d$bias, col = pcol[as.character(pp)], lwd = 1.5)
      points(x, d$bias, pch = ppch[as.character(pp)], col = pcol[as.character(pp)], cex = 1.3)
    }
    points(cellb$recall, cellb$bias, pch = 18, cex = 1.7, col = "grey30")
    text(cellb$recall, cellb$bias, cellb$cell, pos = c(C00 = 2, C01 = 4, C10 = 2, C11 = 4)[cellb$cell], cex = 0.85, col = "grey30")
    if (src == "random") legend("bottomleft", c("p = 1", "p = 0.8", "p = 0.6", "cells of Result 1 (p 0.30 to 0.32)"), bty = "n", cex = 0.8,
                                col = c(pcol, "grey30"), pch = c(ppch, 18), lwd = c(1.5, 1.5, 1.5, NA))
  }
  par(op); dev.off()
} else message("No perturb.csv: S8 figure and tables skipped.")
message("Wrote assets to ", out)
