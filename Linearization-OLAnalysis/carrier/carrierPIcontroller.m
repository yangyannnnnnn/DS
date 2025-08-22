function [mv,err] = carrierPIcontroller(y_ref,y,kp,ti,ts,ub,lb,u_old,err_old)

err = y_ref - y;
delta_mv = kp*(err - err_old) + kp/ti*err*ts;
mv = u_old + delta_mv;
if mv > ub
    mv = ub;
elseif mv < lb
    mv = lb;
end
end

