import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import root_scalar
from tqdm import tqdm
#import math
from scipy.interpolate import interp1d

# ======================== 参数设置 ==========================
pka_points = 10000          
pka_range = (0, 10)        
H_bounds = (1e-14, 1)      
solver_settings = {
    'method': 'brentq',
    'xtol': 1e-12,
    'rtol': 1e-12,
    'maxiter': 300
}
# ====================== 预初始化数组 ========================
pka_array = np.linspace(*pka_range, pka_points)

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
# ====================== 优化后的主计算函数 ========================
def find_zero_point(c, pka_array):
    z_results = np.full_like(pka_array, np.nan)
    min_diff = float('inf')
    idxpka = -1
    
    for idx, pka in enumerate(pka_array):
        Ka = 10 ** (-pka)
        
        # 求解Ha和Hb（添加异常处理）
        try:
            sol_ha = root_scalar(lambda H: equation_ha(H, Ka, c),
                               bracket=H_bounds, **solver_settings)
            Ha = sol_ha.root
            sol_hb = root_scalar(lambda H: equation_hb(H, Ka, c),
                               bracket=H_bounds, **solver_settings)
            Hb = sol_hb.root
            
            # 计算nae和nbe
            H_nae = Ha / 10
            nae = equation_ha(H_nae, Ka, c)
            H_nbe = Hb / 10
            nbe = equation_hb(H_nbe, Ka, c)
            
            z_val = nae - nbe
            z_results[idx] = z_val
            
            # 寻找最接近零的点（改进判断条件）
            if abs(z_val) < min_diff:
                min_diff = abs(z_val)
                idxpka = pka
                
        except ValueError:
            continue
            
    return idxpka

if __name__ == "__main__":
    # c值采样
    c_values = np.arange(0.01, 2.001, 0.01)
    pka_zeros = []
    pka_array = np.linspace(*pka_range, pka_points)
    
    # 计算每个c对应的pKa零点（添加进度条）
    for c in tqdm(c_values, desc='Calculating'):
        zero_point = find_zero_point(c, pka_array)
        pka_zeros.append(zero_point)
    
    # ============== 数据后处理：插值平滑 ==============
    # 过滤无效点
    valid_mask = ~np.isnan(pka_zeros)
    c_valid = c_values[valid_mask]
    pka_valid = np.array(pka_zeros)[valid_mask]
    
    # 创建插值函数（三次样条）
    interp_func = interp1d(c_valid, pka_valid, kind='cubic', fill_value="extrapolate")
    c_smooth = np.linspace(min(c_valid), max(c_valid), 1000)
    pka_smooth = interp_func(c_smooth)
    
    # ====================== 绘图 ========================
    plt.figure(figsize=(12, 6))
    
    # 原始数据点（透明度调低）
    plt.scatter(c_values, pka_zeros, s=5, alpha=0.3, label='Raw Data')
    
    # 插值后的平滑曲线
    plt.plot(c_smooth, pka_smooth, 'r-', linewidth=2, label='Smoothed Curve')
    
    # 标记参考点
    plt.scatter(0.2, 3.02, color='green', s=100, zorder=5, 
               label='Reference (c=0.2, pKa=3.02)')
    
    plt.xlabel('Concentration c (mol/L)', fontsize=12)
    plt.ylabel('pKa at Z=0', fontsize=12)
    plt.title('Smoothed Relationship: c vs pKa at Zero Crossing', fontsize=14)
    plt.grid(True, linestyle=':', alpha=0.5)
    plt.legend()
    plt.tight_layout()
    plt.show()