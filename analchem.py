import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import root_scalar
from tqdm import tqdm
import math

# ======================== 参数设置 ==========================
c = 0.1                     # 固定浓度
pka_points = 10000          # 采样点数
pka_range = (0, 10)         # pKa范围
H_bounds = (1e-14, 1)       # H的物理合理范围
solver_settings = {          # 求解器参数
    'method': 'brentq',
    'xtol': 1e-12,
    'rtol': 1e-12,
    'maxiter': 300
}

# ====================== 预初始化数组 ========================
pka_array = np.linspace(*pka_range, pka_points)
z_results = np.full_like(pka_array, np.nan)

# ====================== 定义核心方程 ========================
def equation_ha(H, Ka, c):
    """Ha对应的方程：(Ka/(H+Ka)*c + 1e-14/H - H - c/2)*25 = 0"""
    try:
        return 25 * ( (Ka/(H + Ka + 1e-30))*c + 1e-14/(H + 1e-30) - H - c/2 )
    except:
        return np.nan

def equation_hb(H, Ka, c):
    """Hb对应的方程：(Ka/(H+Ka)*c + 1e-14/H - H)*25 = 0"""
    try:
        return 25 * ( (Ka/(H + Ka + 1e-30))*c + 1e-14/(H + 1e-30) - H )
    except:
        return np.nan

# ====================== 主计算循环 ========================
for idx, pka in enumerate(tqdm(pka_array, desc='计算进度')):
    Ka = 10 ** (-pka)  # 计算当前Ka值
    
    # ------------------- 求解Ha -------------------
    try:
        sol_ha = root_scalar(
            lambda H: equation_ha(H, Ka, c),
            bracket=H_bounds,
            **solver_settings
        )
        Ha = sol_ha.root
    except ValueError:
        Ha = np.nan
    
    # ------------------- 求解Hb -------------------
    try:
        sol_hb = root_scalar(
            lambda H: equation_hb(H, Ka, c),
            bracket=H_bounds,
            **solver_settings
        )
        Hb = sol_hb.root
    except ValueError:
        Hb = np.nan
    
    # ---------------- 计算nae和nbe ----------------
    if not (np.isnan(Ha) or np.isnan(Hb)):
        try:
            H_nae = Ha / 10
            nae = equation_ha(H_nae, Ka, c) #+ 25 * (H_nae + c/2)  # 重构原式
        except:
            nae = np.nan
        
        try:
            H_nbe = Hb / 10
            nbe = equation_hb(H_nbe, Ka, c) #+ 25 * H_nbe          # 重构原式
        except:
            nbe = np.nan
        
        # ---------------- 计算最终z值 ----------------
        if not (np.isnan(nae) or np.isnan(nbe)):
            z_results[idx] = nae - nbe
            #pka=3.02 for c=0.2
            if -1e-3<nae-nbe<1e-3:
                print(pka,nae-nbe)

# ====================== 数据后处理 ========================
valid_mask = ~np.isnan(z_results)
pka_clean = pka_array[valid_mask]
z_clean = z_results[valid_mask]

# ====================== 可视化设置 ========================
plt.figure(figsize=(12, 6), facecolor='white')
plt.plot(pka_clean, z_clean, 
         color='#2E86C1', 
         linewidth=1.5,
         label='Z值曲线')

plt.xlabel('pKa', fontsize=12, fontfamily='Arial')
plt.ylabel('Z = NAE - NBE', fontsize=12, fontfamily='Arial')
#plt.title('酸碱平衡参数关系分析', fontsize=14, fontweight='bold')
plt.grid(True, linestyle='--', alpha=0.6)
plt.xlim(pka_range)

# 添加科学注释
plt.text(0.05, 0.95, 
         f'c = {c} mol/L\nn = {pka_points} points\nValid points: {len(z_clean)}',
         transform=plt.gca().transAxes,
         verticalalignment='top',
         bbox=dict(facecolor='white', alpha=0.8))

plt.tight_layout()
plt.show()