def getFactor(wt_unit, cal_unit):
    if wt_unit == 'kg' and cal_unit == 'cal':
        factor = 13 * 2.20462
    elif wt_unit == 'kg' and cal_unit == 'kj':
        factor = 13 * 2.20462 * 4.184
    elif wt_unit == 'lb' and cal_unit == 'cal':
        factor = 13
    else:
        factor = 13 * 4.184
    return factor


def getCurrentTDEE(weight, wt_unit, cal_unit):
    factor = getFactor(wt_unit, cal_unit)
    if new_user:
        return weight * factor
    else:
        last week weight = getLastWeekWeight(user_name)
        current_week_weight = getCurrentWeekWeight(user_name)
        wt_lost = last_week_weight - current_week_weight
        factored_wt = (wt_lost * factor)/no_of_time_used_last week
        avg_week_wt = getAverageWeeklyWeight(user_name)
        new_TDEE = (avg_week_wt + factored_wt)/(len(avg_week_wt) + 1)


