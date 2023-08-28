function u = input_func_1(time_vec)
    u1 = utils.ustep(time_vec, 3);
    u2 = - utils.ustep(time_vec, 4);
    u3 = utils.ustep(time_vec, 4) * 0.5;
    u4 = - utils.ustep(time_vec, 10) * 0.5;
    u5 = utils.ustep(time_vec, 10) * -2;
    u6 = - utils.ustep(time_vec, 15) * -2;

    u = u1 + u2 + u3 + u4 + u5 + u6;
end