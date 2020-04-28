library(dplyr)

setwd("/Users/seungyoungoh/workspace/classification_obesity_risk_groups/Data")
df18 <- read.csv("국민건강영양조사(2018).csv", header = T)
dm_df <- df18

# dataframe에 새로운 column을 추가하는 코드
# HE_obe: 1, 2: 저체중, 정상
dm_df$is_obe <- ifelse(dm_df$HE_obe == 1 | dm_df$HE_obe == 2, 0, 1)

# 우리의 예측에 해당하지 않는, 체중 변화 여부를 무응답하거나 소아인 경우를 제외
# BO1_1 == 8, 9 인 경우
dm_df <- dm_df %>% filter(dm_df$BO1_1 != 8 & dm_df$BO1_1 != 9)

# danger가 No이면 정상, Yes이면 위험
# BO1_1 == 3 : 체중 증가
dm_df$danger <- ifelse(dm_df$is_obe == 1 & dm_df$BO1_1 == 3, 1, 0)

#table(is.na(dm_df))
# 필요없어진 is_obe 변수를 제거,
dm_df <- dm_df %>% select(-is_obe)


# 결측치가 많이 발견되어 검사에 무리를 준 특성을 제거
# 관련 없는 특성의 제거
dm_df <- dm_df %>% select(-age_month, - wt_pft, - wt_vt, - wt_nn, - wt_pfnt, - wt_pfvt, - wt_pfvtnt, - wt_vtnt, - wt_nnnt,
                          - BH9_14_1_01, - BH9_14_2_01, - BH9_14_3_01, - BH9_14_1_02, - BH9_14_2_02, - BH9_14_3_02, - BH9_14_1_03,
                          - BH9_14_2_03, - BH9_14_3_03, - AC3_1_01, - AC3_2_01, - AC3_3_01, - AC8_1_01, - AC3_4_01, - AC8_2w_01,
                          - AC8_2_01, - AC8_3w_01, - AC8_3_01, - AC3_1_02, - AC3_2_02, - AC3_3_02, - AC8_1_02, - AC3_4_02,
                          - AC8_2w_02, - AC8_2_02, - AC8_3w_02, - AC8_3_02, - AC3_1_03, - AC3_2_03, - AC3_3_03, - AC8_1_03,
                          - AC3_4_03, - AC8_2w_03, - AC8_2_03, - AC8_3w_03, - AC8_3_03, - sc_seatblt, - sc_seatblt2, - LW_ms,
                          - LW_mp_a, - LW_ms_a, - LW_pr, - LW_pr_1, - LW_mt, - LW_mt_a1, - LW_mt_a2, - LW_br, - LW_br_ch,
                          - LW_br_dur, - LW_br_yy, - LW_br_mm, - LW_oc, - HE_dprg, - HE_mPLS, - HE_wt_pct, - HE_BMI_pct,
                          - HE_Folate, - HE_VitA, - HE_VitE, - HE_NNAL, - HE_cough1, - HE_cough2, - HE_sput1, - HE_sput2,
                          - HE_PFTdr, - HE_PFTag, - HE_PFTtr, - HE_PFThs, - Y_BTH_WT, - Y_MTM_YN, - Y_MTM_S1, - Y_MTM_S2,
                          - Y_MTM_D1, - Y_MTM_D2, - Y_FM_YN, - Y_FM_S1, - Y_FM_S2, - Y_FM_D1, - Y_FM_D2, - Y_MLK_ST, - Y_WN_ST,
                          - Y_SUP_YN, - Y_SUP_KD1, - Y_SUP_KD3, - Y_SUP_KD4, - Y_SUP_KD7, - N_BFD_Y, - wt_hs) %>%
                          select(-HE_obe, - HE_HDL_st2, - HE_chol, - HE_HDL_st2, - HE_TG, - HE_LDL_drct, - HE_HCHOL, - HE_HTG, - HE_HBsAg,
                            - HE_ast, - HE_alt, - HE_hepaB, - ID, - BO1_3, - ID_fam, - id_M, - id_F, - LW_mp_e, - BO1_1, - HE_wc, - HE_wt,
                            - HE_BMI, - psu, - BO1_2, - BO1, - fam_rela, - region)

# 아래부터 오승영이 추가한 data cleansing 코드

src_data <- dm_df %>% select(-X,-mod_d, -DE1_35, -DC11_tp, -DC12_tp, -M_2_et, -BH9_14_4_02, -N_DT_DS, -N_DT_DS, -AC3_3e_01, -AC8_1e_01,
                          -AC3_3e_02, -LQ4_24, -BH9_14_4_01, -N_DAY)

src_data <- src_data[,-grep("etc", names(src_data))]
src_data <- src_data[,-grep("ETC", names(src_data))]
# etc 가 포함된 feature은 값에 부등호가 포함됨

cat("본래 데이터 열 개수: ",length(df18), ", 현재 데이터 열 개수:", length(src_data),"\n")


# 각 열의 결측치 개수를 센다.
# apply(src_data, 2, function(x) {sum(is.na(x))})

pre_cleaned_data <- src_data

for (i in 1:length(src_data))
{
  #결측치 > 2000 이면 해당 열을 제외한다.
  if(sum(is.na(src_data[i])) > 2000){
    pre_cleaned_data <- pre_cleaned_data %>% select(-names(src_data[i]))
    
    # print(names(pre_cleaned_data[i]))
    # "BH9_14_4_03" 인플루엔자 상세
    # "AC8_1e_02" 손상 치료 기타 상세
    # "AC3_3e_03" 손상 치료 기타 상세
    # "AC8_1e_03" 손상 치료 기타 상세
    # "BS12_45" 현재 사용 담배 종류
    # "BM13_6" 치아 손상 사유
  }
}

cat(length(src_data)-length(pre_cleaned_data), "개의 결측치가 2000개 이상인 열 제거\n")

# 만약 결측치 1000 이상인 경우를 살펴보면 다음과 같은 열들이 선택된다.
#  "BH1" 건강 검진 수진 여부 
#  "MH1_yr" 1년간 입원 이용 여부
#  "MH1_1"  입원 이용 횟수 
#  "MO1_wk" 2주간 외래 이용 여부
#  "BS10_3" 최근 1달 동안 담배를 피운 날 하루 평균 몇 개비를 피웠나
#  "HE_UNa_etc" 요나트륨 장비분석범위
#  "MO4_4" 진료항목: 구강검사?


cleaned_data <- na.omit(pre_cleaned_data)
cat(nrow(pre_cleaned_data)-nrow(cleaned_data), "개의 결측치가 포함된 행 제거\n")
summary(cleaned_data)