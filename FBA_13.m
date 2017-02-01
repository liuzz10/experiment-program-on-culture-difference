%测试时可将darktime改成更小的数(必须是8的倍数)节约时间 
%变暗间隔1800-2000ms，持续500ms.变暗前200ms闪烁，闪烁持续100ms
%红色变暗32次
%不遮盖注视点
%min_seq= [1 2 3 3 4 5 6 6]
%1for红暗红闪，2for红暗绿闪，3for红暗不闪
%4for绿暗红闪，5for绿暗绿闪，6for绿暗不闪
%记录sProbe(1for红暗红闪，2for红暗绿闪，3for红暗不闪),tRTs(反应时),tPress(按键时刻)
%修改计数变量
%56练习+112正式+112正式
%darktimePractice = 56;              
%darktime = 112; 
%将三部分改为四部分

function FBA
Screen('Preference', 'SkipSyncTests', 1);
AssertOpenGL;

ID = input('The subject"s ID：', 's'); 
sex = input('Enter m for male & f for female:', 's');   %记录被试ID和性别
sSec=zeros(300,1);      %第几部分，0为练习，1-2为正式试验
sPart=zeros(300,1);     %变暗标记，0-5
sProbe=zeros(300,1);    %标记红色变暗下三种情况
tPress=zeros(300,1);    %记录按键时刻
tDark=zeros(300,1);     %记录红色变暗时刻
tRTs =zeros(300,1);     %记录反应时
nPress=1;              %一次变暗内第几次按键
nDark=2;               %第几次红色变暗

try
    screens=Screen('Screens'); 
    screenNumber=max(screens);
    [w, rect] = Screen('OpenWindow', screenNumber, 0,[], 32, 2);
    
    mon_width   = 30;              % 屏幕宽度(cm) 
    v_dist      = 50;              % 人眼到屏幕的距离(cm)
    ndots       = 50;              % 前景点数量
    ndots_right = 900;             % 背景点数量
    ppd         = pi * (rect(3)-rect(1)) / atan(mon_width/v_dist/2) / 360;  % 1度视角的像素个数(pixels per degree )
    max_in      = 4;               % 圆形区域的半径(deg)
    min_in      = 0.25;            % minumum 圆的最小环面半径
    rmax_in     = max_in * ppd;    % 圆形区域的半径(pixel)
    rmin_in     = min_in * ppd;     
    max_out     = 18;              % 背景的外径
    min_out     = 5;               % 背景的内径
    rmax_out    = max_out * ppd;   % 背景的外径
    rmin_out    = min_out * ppd;   % 背景的内径
    dot_w       = 0.2;             % 点的宽度(deg)
    s           = dot_w * ppd;     % 点的宽度(pixel)
    fix_r       = 0.15;            % 中心注视点的宽度(deg)
    [center(1), center(2)] = RectCenter(rect);              %中心注视点的坐标(pixel)
    centerLeft(1) = center(1);
    centerLeft(2) = center(2);
    centerRight(1) = center(1);
    centerRight(2) = center(2);
    fix_cord = [center-fix_r*ppd center+fix_r*ppd];         % 中心点坐标
    KbName('UnifyKeyNames');
    responseKey = KbName('j');
    triggerKey = KbName('space');
    onExit = 'execution halted by experimenter';
    
    %图片信息
    picPre1 = 'pre1.jpg';
    picPre2 = 'pre2.jpg';
    picPra1 = 'pra1.jpg';
    picPra2 = 'pra2.jpg';
    picSec1 = 'sec1.jpg';
    picSec2 = 'sec2.jpg';
    picEnd1 = 'end1.jpg';
    picEnd2 = 'end2.jpg';
    picEnd3 = 'end3.jpg';
    picEnd4 = 'end4.jpg';
    picEnd = {picEnd1, picEnd2, picEnd3, picEnd4};
    
    %初始时间
    start = GetSecs;
    pressT = start;
 
    %初始屏幕的数值
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    fps=Screen('FrameRate',w);           %fps = frames per second
    ifi=Screen('GetFlipInterval', w);    %ifi = 显示器翻转间隔
    if fps==0
       fps=1/ifi;
    end;
    
    %点的距离
    rRed1 = (rmax_in-rmin_in) * sqrt(rand(ndots,1))+rmin_in;     %Red1表示中央的红色点集 
    rGreen1 = (rmax_in-rmin_in) * sqrt(rand(ndots,1))+rmin_in;   %Green1表示中央的绿色点集
    rRight = (rmax_out-rmin_out) * sqrt(rand(ndots_right,1))+rmin_out;    %Right表示外周的点集
 
    %点的角度
    tRed1 = 2*pi*rand(ndots,1);  
    csRed1 = [cos(tRed1), sin(tRed1)];
    tGreen1 = 2*pi*rand(ndots,1);                    
    csGreen1 = [cos(tGreen1), sin(tGreen1)];
    tRight = 2*pi*rand(ndots_right,1);                     
    csRight = [cos(tRight), sin(tRight)];
    
    %点的坐标
    xyRed1 = [rRed1 rRed1] .* csRed1;   
    xyGreen1 = [rGreen1 rGreen1] .* csGreen1;
   
    %点的颜色(RGB值)
    white = WhiteIndex(w);      %注视点颜色
    red1 = zeros(3,ndots);      %左边红色
    red1(1,:) = 255;
    colvectRed1 = uint8(round(red1));
    green1 = zeros(3,ndots);    %左边绿色
    green1(2,:) = 128;
    colvectGreen1 = uint8(round(green1));
    red2 = zeros(3,ndots_right);      %右边红色
    red2(1,:) = 255;
    colvectRed2 = uint8(round(red2));
    green2 = zeros(3,ndots_right);    %右边绿色
    green2(2,:) = 128;
    colvectGreen2 = uint8(round(green2));
    black = zeros(3,ndots_right);    %右边黑色
    colvectBlack = uint8(round(black));
    color = 1;                  %判断左边的颜色，1为红色，2为绿色

    %时间计数参数
    SOA = 2;                           %右边闪烁后与左边变暗的时间间隔
    timeColorDark = 5;                 %左边点变暗时间长度
    countColorDarkRed1 = 1;            %左边红色点变暗时间长度计数
    countColorDarkGreen1 = 1;          %左边绿色点变暗时间长度计数
    darktimePractice = 8;              %练习一共会变暗的次数
    darktime = 8;                     %正式实验的一个sec会变暗的次数
    endtime1 = 2;
    endtime2 = 2;
    
    HideCursor;                          %隐藏鼠标
    Priority(MaxPriority(w));            %设置屏幕优先级
    
    for j = 1:4
        countFrame = 1;                    %每次变暗后第几个100ms
        countDark = 1;                     %第几次变暗
        ifDark = 0;                        %判断点是否变暗   
        ifFlash = 0;                       %右边是否闪烁

        %生成随机的时间间隔   
        darkInterval = zeros(1,darktimePractice);  
        for i = 1:darktimePractice
            darkInterval(i) = unidrnd(3)+17;
        end
        %设置伪随机数
        min_seq= [1 2 3 3 4 5 6 6];
        seq_order = zeros(darktimePractice,1);  %1for红暗红闪，2for红暗绿闪，3for红暗不闪，4for绿暗红闪，5for绿暗绿闪，6for绿暗不闪
        cnt = 1;
        for i = 1:darktimePractice/length(min_seq)
            rand_one= randperm(length(min_seq));
            seq_order(cnt:cnt+length(min_seq)-1) = min_seq(rand_one);
            cnt = cnt + length(min_seq);
        end
        %nframes长度为darkInterval的总和加上后面的1000ms（因为结尾500ms不变暗，最后一次变暗需要500ms）
        nframes = 10 + sum(darkInterval);
        
        %正式实验开始
        %指导语pre1
        if j == 1 
            img = imread(picPre1);
        else
            img = imread(picPre2);
        end
        textureIndex = Screen('MakeTexture', w, img);
        Screen('DrawTexture',w, textureIndex);
        vbl=Screen('Flip', w);              
        WaitSecs(2);
        is_true = 0;
        while (is_true == 0)
            [keyIsDown,sec,keyCode] = KbCheck;     
                if keyIsDown && keyCode(triggerKey)    
                   is_true = 1;              
                end
        end
        %练习实验
        %指导语pra1
        if j == 1 
            img = imread(picPra1);
        else
            img = imread(picPra2);
        end
        textureIndex = Screen('MakeTexture', w, img);
        Screen('DrawTexture',w, textureIndex);
        vbl=Screen('Flip', w);              
        WaitSecs(2);
        is_true = 0;
        while (is_true == 0)
            [keyIsDown,sec,keyCode] = KbCheck;     
                if keyIsDown && keyCode(triggerKey)    
                   is_true = 1;              
                end
        end
        %注视点先呈现1秒
        Screen('FillOval', w, uint8(white), fix_cord);
        vbl=Screen('Flip', w);               
        WaitSecs(1);
        %循环开始
        for i = 1:nframes
            tempT = GetSecs;
            %左边点位置变换
            if (mod(i,2)==1)
                %随机选一半点随机分配新位置
                sortSeedRed1 = rand(ndots,1);
                [A,indexRed1] = sort(sortSeedRed1);
                changeRed1 = indexRed1(1:ndots/2,:);
                remainRed1 = indexRed1((ndots/2+1):ndots,:);
                rRed1(changeRed1) = (rmax_in-rmin_in) * sqrt(rand(ndots/2,1))+rmin_in;                                   
                tRed1(changeRed1) = 2*pi*rand(ndots/2,1);                     
                csRed1(changeRed1,:) = [cos(tRed1(changeRed1)), sin(tRed1(changeRed1))]; 
                xyRed1(changeRed1,:) = [rRed1(changeRed1) rRed1(changeRed1)] .* csRed1(changeRed1,:); 

                sortSeedGreen1 = rand(ndots,1);
                [A,indexGreen1] = sort(sortSeedGreen1);
                changeGreen1 = indexGreen1(1:ndots/2,:);
                remainGreen1 = indexGreen1((ndots/2+1):ndots,:);
                rGreen1(changeGreen1) = (rmax_in-rmin_in) * sqrt(rand(ndots/2,1))+rmin_in;                                   
                tGreen1(changeGreen1) = 2*pi*rand(ndots/2,1);                     
                csGreen1(changeGreen1,:) = [cos(tGreen1(changeGreen1)), sin(tGreen1(changeGreen1))]; 
                xyGreen1(changeGreen1,:) = [rGreen1(changeGreen1) rGreen1(changeGreen1)] .* csGreen1(changeGreen1,:); 

                xymatrixRed1 = transpose(xyRed1);
                xymatrixGreen1 = transpose(xyGreen1);

            else
                %偶数个frame时将剩下的另一半点随机分配新位置
                rRed1(remainRed1) = (rmax_in-rmin_in) * sqrt(rand(ndots/2,1))+rmin_in;                                   
                tRed1(remainRed1) = 2*pi*rand(ndots/2,1);                     
                csRed1(remainRed1,:) = [cos(tRed1(remainRed1)), sin(tRed1(remainRed1))]; 
                xyRed1(remainRed1,:) = [rRed1(remainRed1) rRed1(remainRed1)] .* csRed1(remainRed1,:); 

                rGreen1(remainGreen1) = (rmax_in-rmin_in) * sqrt(rand(ndots/2,1))+rmin_in;                                   
                tGreen1(remainGreen1) = 2*pi*rand(ndots/2,1);                     
                csGreen1(remainGreen1,:) = [cos(tGreen1(remainGreen1)), sin(tGreen1(remainGreen1))]; 
                xyGreen1(remainGreen1,:) = [rGreen1(remainGreen1) rGreen1(remainGreen1)] .* csGreen1(remainGreen1,:); 

                xymatrixRed1 = transpose(xyRed1);
                xymatrixGreen1 = transpose(xyGreen1);      
            end;

            %判定闪烁和变暗
            if (countDark <= darktimePractice)
                if (countFrame < darkInterval(countDark))
                    if (countFrame == darkInterval(countDark)-SOA)
                        ifFlash = 1;
                    end
                    countFrame = countFrame + 1;
                else
                    countFrame = 1;
                    ifDark = 1;
                    countDark = countDark + 1;
                end
            end

            %外围点闪烁
            if (ifFlash == 1)
                rRight  = (rmax_out-rmin_out) * sqrt(rand(ndots_right,1))+rmin_out; 
                tRight  = 2*pi*rand(ndots_right,1);                    
                csRight = [cos(tRight), sin(tRight)];    
                xyRight = [rRight rRight] .* csRight;
                xymatrixRight = transpose(xyRight);
                switch seq_order(countDark)
                    case 1
                        color = 1;
                        colvectRight = colvectRed2;
                        sProbe(nDark)=1;
                    case 2
                        color = 1;
                        colvectRight = colvectGreen2;
                        sProbe(nDark)=2;
                    case 3
                        color = 1;
                        colvectRight = colvectBlack;
                        sProbe(nDark)=3;
                    case 4
                        color = 2;
                        colvectRight = colvectRed2;
                    case 5
                        color = 2;
                        colvectRight = colvectGreen2;
                    otherwise
                        color = 2;
                        colvectRight = colvectBlack;
                end
                Screen('DrawDots', w, xymatrixRight, s, colvectRight, centerRight,0); 
                ifFlash = 0;
            end

            %中央点颜色变暗
            if (ifDark == 1)           
                if (color == 1) %红色变暗
                    red1 = zeros(3,ndots); 
                    red1(1,:) = 120; 
                    colvectRed1 = uint8(round(red1)); 
                    countColorDarkRed1 = countColorDarkRed1 +1;  %时间计数
                    if (countColorDarkRed1 > timeColorDark)  %变暗500ms
                        red1 = zeros(3,ndots);
                        red1(1,:) = 255;
                        colvectRed1 = uint8(round(red1));
                        countColorDarkRed1 = 1;              
                        ifDark = 0;
                    end
                else               
                    green1 = zeros(3,ndots); %绿色变暗
                    green1(2,:) = 60;
                    colvectGreen1 = uint8(round(green1)); 
                    countColorDarkGreen1 = countColorDarkGreen1 +1;    %时间计数
                    if (countColorDarkGreen1 > timeColorDark)  %变暗500ms
                        green1 = zeros(3,ndots);
                        green1(2,:) = 128;
                        colvectGreen1 = uint8(round(green1));
                        countColorDarkGreen1 = 1;              
                        ifDark = 0;
                    end
                end
            end

            %画注视点
            Screen('FillOval', w, uint8(white), fix_cord);  
            %画中央红绿点
            Screen('DrawDots', w, xymatrixRed1, s, colvectRed1, centerLeft,0);  
            Screen('DrawDots', w, xymatrixGreen1, s, colvectGreen1, centerLeft,0);          
            Screen('DrawingFinished', w); 
            vbl = Screen('Flip', w , vbl + 0.5*ifi);

            %变暗时刻
            if countColorDarkGreen1 == 2               
                sSec(nDark) = 0;
                sPart(nDark) = j;
                tDark(nDark) = GetSecs - start;
                nDark = nDark+1;
                nPress = 1;
            end

            %检测按键
            while  GetSecs - tempT <= 0.1
                [keyIsDown, secs, keyCode] = KbCheck;
                 assert(~keyCode(KbName('Escape')),onExit);
                if keyCode(responseKey)
                    if  secs-pressT > 0.3 && tDark(nDark-1)~=0      %排除连续按键
                        tPress(nDark-1,nPress) = secs - start;           %按键时刻
                        tRTs(nDark-1) = tPress(nDark-1,1) - tDark(nDark-1);     %反应时=按键时刻-变暗时刻
                        nPress = nPress+1;
                        pressT = secs; 
                    end                
                end
            end  

        end;
        %循环结束
        %正式实验sec1
        countFrame = 1;                    %每次变暗后第几个100ms
        countDark = 1;                     %第几次变暗
        ifDark = 0;                        %判断点是否变暗   
        ifFlash = 0;                       %右边是否闪烁
        darkInterval = zeros(1,darktime);  
        for i = 1:darktime
            darkInterval(i) = unidrnd(3)+17;
        end
        %设置伪随机数
        min_seq= [1 2 3 3 4 5 6 6];
        seq_order = zeros(darktime,1);  %1for红暗红闪，2for红暗绿闪，3for红暗不闪，4for绿暗红闪，5for绿暗绿闪，6for绿暗不闪
        cnt = 1;
        for i = 1:darktime/length(min_seq)
            rand_one= randperm(length(min_seq));
            seq_order(cnt:cnt+length(min_seq)-1) = min_seq(rand_one);
            cnt = cnt + length(min_seq);
        end 
        nframes = 10 + sum(darkInterval);
        %指导语sec1
        img = imread(picSec1);
        textureIndex = Screen('MakeTexture', w, img);
        Screen('DrawTexture',w, textureIndex);
        vbl=Screen('Flip', w);               %初始刷一次屏幕
        is_true = 0;
        while (is_true == 0)
            [keyIsDown,sec,keyCode] = KbCheck;     
                if keyIsDown && keyCode(triggerKey)    
                   is_true = 1;              
                end
        end 
        %注视点先呈现1秒
        Screen('FillOval', w, uint8(white), fix_cord);
        vbl=Screen('Flip', w);               
        WaitSecs(1);
        %循环开始
        for i = 1:nframes
            tempT = GetSecs;
            %左边点位置变换
            if (mod(i,2)==1)
                %随机选一半点随机分配新位置
                sortSeedRed1 = rand(ndots,1);
                [A,indexRed1] = sort(sortSeedRed1);
                changeRed1 = indexRed1(1:ndots/2,:);
                remainRed1 = indexRed1((ndots/2+1):ndots,:);
                rRed1(changeRed1) = (rmax_in-rmin_in) * sqrt(rand(ndots/2,1))+rmin_in;                                   
                tRed1(changeRed1) = 2*pi*rand(ndots/2,1);                     
                csRed1(changeRed1,:) = [cos(tRed1(changeRed1)), sin(tRed1(changeRed1))]; 
                xyRed1(changeRed1,:) = [rRed1(changeRed1) rRed1(changeRed1)] .* csRed1(changeRed1,:); 

                sortSeedGreen1 = rand(ndots,1);
                [A,indexGreen1] = sort(sortSeedGreen1);
                changeGreen1 = indexGreen1(1:ndots/2,:);
                remainGreen1 = indexGreen1((ndots/2+1):ndots,:);
                rGreen1(changeGreen1) = (rmax_in-rmin_in) * sqrt(rand(ndots/2,1))+rmin_in;                                   
                tGreen1(changeGreen1) = 2*pi*rand(ndots/2,1);                     
                csGreen1(changeGreen1,:) = [cos(tGreen1(changeGreen1)), sin(tGreen1(changeGreen1))]; 
                xyGreen1(changeGreen1,:) = [rGreen1(changeGreen1) rGreen1(changeGreen1)] .* csGreen1(changeGreen1,:); 

                xymatrixRed1 = transpose(xyRed1);
                xymatrixGreen1 = transpose(xyGreen1);

            else
                %偶数个frame时将剩下的另一半点随机分配新位置
                rRed1(remainRed1) = (rmax_in-rmin_in) * sqrt(rand(ndots/2,1))+rmin_in;                                   
                tRed1(remainRed1) = 2*pi*rand(ndots/2,1);                     
                csRed1(remainRed1,:) = [cos(tRed1(remainRed1)), sin(tRed1(remainRed1))]; 
                xyRed1(remainRed1,:) = [rRed1(remainRed1) rRed1(remainRed1)] .* csRed1(remainRed1,:); 

                rGreen1(remainGreen1) = (rmax_in-rmin_in) * sqrt(rand(ndots/2,1))+rmin_in;                                   
                tGreen1(remainGreen1) = 2*pi*rand(ndots/2,1);                     
                csGreen1(remainGreen1,:) = [cos(tGreen1(remainGreen1)), sin(tGreen1(remainGreen1))]; 
                xyGreen1(remainGreen1,:) = [rGreen1(remainGreen1) rGreen1(remainGreen1)] .* csGreen1(remainGreen1,:); 

                xymatrixRed1 = transpose(xyRed1);
                xymatrixGreen1 = transpose(xyGreen1);      
            end;

            %判定闪烁和变暗
            if (countDark <= darktime)
                if (countFrame < darkInterval(countDark))
                    if (countFrame == darkInterval(countDark)-SOA)
                        ifFlash = 1;
                    end
                    countFrame = countFrame + 1;
                else
                    countFrame = 1;
                    ifDark = 1;
                    countDark = countDark + 1;
                end
            end

            %外围点闪烁
            if (ifFlash == 1)
                rRight  = (rmax_out-rmin_out) * sqrt(rand(ndots_right,1))+rmin_out; 
                tRight  = 2*pi*rand(ndots_right,1);                    
                csRight = [cos(tRight), sin(tRight)];    
                xyRight = [rRight rRight] .* csRight;
                xymatrixRight = transpose(xyRight);
                switch seq_order(countDark)
                    case 1
                        color = 1;
                        colvectRight = colvectRed2;
                        sProbe(nDark)=1;
                    case 2
                        color = 1;
                        colvectRight = colvectGreen2;
                        sProbe(nDark)=2;
                    case 3
                        color = 1;
                        colvectRight = colvectBlack;
                        sProbe(nDark)=3;
                    case 4
                        color = 2;
                        colvectRight = colvectRed2;
                    case 5
                        color = 2;
                        colvectRight = colvectGreen2;
                    otherwise
                        color = 2;
                        colvectRight = colvectBlack;
                end
                Screen('DrawDots', w, xymatrixRight, s, colvectRight, centerRight,0); 
                ifFlash = 0;
            end

            %中央点颜色变暗
            if (ifDark == 1)           
                if (color == 1) %红色变暗
                    red1 = zeros(3,ndots); 
                    red1(1,:) = 120; 
                    colvectRed1 = uint8(round(red1)); 
                    countColorDarkRed1 = countColorDarkRed1 +1;  %时间计数
                    if (countColorDarkRed1 > timeColorDark)  %变暗500ms
                        red1 = zeros(3,ndots);
                        red1(1,:) = 255;
                        colvectRed1 = uint8(round(red1));
                        countColorDarkRed1 = 1;              
                        ifDark = 0;
                    end
                else               
                    green1 = zeros(3,ndots); %绿色变暗
                    green1(2,:) = 60;
                    colvectGreen1 = uint8(round(green1)); 
                    countColorDarkGreen1 = countColorDarkGreen1 +1;    %时间计数
                    if (countColorDarkGreen1 > timeColorDark)  %变暗500ms
                        green1 = zeros(3,ndots);
                        green1(2,:) = 128;
                        colvectGreen1 = uint8(round(green1));
                        countColorDarkGreen1 = 1;              
                        ifDark = 0;
                    end
                end
            end

            %画注视点
            Screen('FillOval', w, uint8(white), fix_cord);  
            %画中央红绿点
            Screen('DrawDots', w, xymatrixRed1, s, colvectRed1, centerLeft,0);  
            Screen('DrawDots', w, xymatrixGreen1, s, colvectGreen1, centerLeft,0);          
            Screen('DrawingFinished', w); 
            vbl = Screen('Flip', w , vbl + 0.5*ifi);

            %变暗时刻
            if countColorDarkGreen1 == 2               
                sSec(nDark) = 1;
                sPart(nDark) = j;
                tDark(nDark) = GetSecs - start;
                nDark = nDark+1;
                nPress = 1;
            end

            %检测按键
            while  GetSecs - tempT <= 0.1
                [keyIsDown, secs, keyCode] = KbCheck;
                 assert(~keyCode(KbName('Escape')),onExit);
                if keyCode(responseKey)
                    if  secs-pressT > 0.3 && tDark(nDark-1)~=0      %排除连续按键
                        tPress(nDark-1,nPress) = secs - start;           %按键时刻
                        tRTs(nDark-1) = tPress(nDark-1,1) - tDark(nDark-1);     %反应时=按键时刻-变暗时刻
                        nPress = nPress+1;
                        pressT = secs; 
                    end                
                end
            end  

        end;  

        %正式实验sec2
        countFrame = 1;                    %每次变暗后第几个100ms
        countDark = 1;                     %第几次变暗
        ifDark = 0;                        %判断点是否变暗   
        ifFlash = 0;                       %右边是否闪烁
        darkInterval = zeros(1,darktime);  
        for i = 1:darktime
            darkInterval(i) = unidrnd(3)+17;
        end
        %设置伪随机数
        min_seq= [1 2 3 3 4 5 6 6];
        seq_order = zeros(darktime,1);  %1for红暗红闪，2for红暗绿闪，3for红暗不闪，4for绿暗红闪，5for绿暗绿闪，6for绿暗不闪
        cnt = 1;
        for i = 1:darktime/length(min_seq)
            rand_one= randperm(length(min_seq));
            seq_order(cnt:cnt+length(min_seq)-1) = min_seq(rand_one);
            cnt = cnt + length(min_seq);
        end
        nframes = 10 + sum(darkInterval);
        %指导语sec2
        img = imread(picSec2);
        textureIndex = Screen('MakeTexture', w, img);
        Screen('DrawTexture',w, textureIndex);
        vbl=Screen('Flip', w);               %初始刷一次屏幕
        is_true = 0;
        while (is_true == 0)
            [keyIsDown,sec,keyCode] = KbCheck;     
                if keyIsDown && keyCode(triggerKey)    
                   is_true = 1;              
                end
        end
        %循环开始
        for i = 1:nframes
            tempT = GetSecs;
            %左边点位置变换
            if (mod(i,2)==1)
                %随机选一半点随机分配新位置
                sortSeedRed1 = rand(ndots,1);
                [A,indexRed1] = sort(sortSeedRed1);
                changeRed1 = indexRed1(1:ndots/2,:);
                remainRed1 = indexRed1((ndots/2+1):ndots,:);
                rRed1(changeRed1) = (rmax_in-rmin_in) * sqrt(rand(ndots/2,1))+rmin_in;                                   
                tRed1(changeRed1) = 2*pi*rand(ndots/2,1);                     
                csRed1(changeRed1,:) = [cos(tRed1(changeRed1)), sin(tRed1(changeRed1))]; 
                xyRed1(changeRed1,:) = [rRed1(changeRed1) rRed1(changeRed1)] .* csRed1(changeRed1,:); 

                sortSeedGreen1 = rand(ndots,1);
                [A,indexGreen1] = sort(sortSeedGreen1);
                changeGreen1 = indexGreen1(1:ndots/2,:);
                remainGreen1 = indexGreen1((ndots/2+1):ndots,:);
                rGreen1(changeGreen1) = (rmax_in-rmin_in) * sqrt(rand(ndots/2,1))+rmin_in;                                   
                tGreen1(changeGreen1) = 2*pi*rand(ndots/2,1);                     
                csGreen1(changeGreen1,:) = [cos(tGreen1(changeGreen1)), sin(tGreen1(changeGreen1))]; 
                xyGreen1(changeGreen1,:) = [rGreen1(changeGreen1) rGreen1(changeGreen1)] .* csGreen1(changeGreen1,:); 

                xymatrixRed1 = transpose(xyRed1);
                xymatrixGreen1 = transpose(xyGreen1);

            else
                %偶数个frame时将剩下的另一半点随机分配新位置
                rRed1(remainRed1) = (rmax_in-rmin_in) * sqrt(rand(ndots/2,1))+rmin_in;                                   
                tRed1(remainRed1) = 2*pi*rand(ndots/2,1);                     
                csRed1(remainRed1,:) = [cos(tRed1(remainRed1)), sin(tRed1(remainRed1))]; 
                xyRed1(remainRed1,:) = [rRed1(remainRed1) rRed1(remainRed1)] .* csRed1(remainRed1,:); 

                rGreen1(remainGreen1) = (rmax_in-rmin_in) * sqrt(rand(ndots/2,1))+rmin_in;                                   
                tGreen1(remainGreen1) = 2*pi*rand(ndots/2,1);                     
                csGreen1(remainGreen1,:) = [cos(tGreen1(remainGreen1)), sin(tGreen1(remainGreen1))]; 
                xyGreen1(remainGreen1,:) = [rGreen1(remainGreen1) rGreen1(remainGreen1)] .* csGreen1(remainGreen1,:); 

                xymatrixRed1 = transpose(xyRed1);
                xymatrixGreen1 = transpose(xyGreen1);      
            end;

            %判定闪烁和变暗
            if (countDark <= darktime)
                if (countFrame < darkInterval(countDark))
                    if (countFrame == darkInterval(countDark)-SOA)
                        ifFlash = 1;
                    end
                    countFrame = countFrame + 1;
                else
                    countFrame = 1;
                    ifDark = 1;
                    countDark = countDark + 1;
                end
            end

            %外围点闪烁
            if (ifFlash == 1)
                rRight  = (rmax_out-rmin_out) * sqrt(rand(ndots_right,1))+rmin_out; 
                tRight  = 2*pi*rand(ndots_right,1);                    
                csRight = [cos(tRight), sin(tRight)];    
                xyRight = [rRight rRight] .* csRight;
                xymatrixRight = transpose(xyRight);
                switch seq_order(countDark)
                    case 1
                        color = 1;
                        colvectRight = colvectRed2;
                        sProbe(nDark)=1;
                    case 2
                        color = 1;
                        colvectRight = colvectGreen2;
                        sProbe(nDark)=2;
                    case 3
                        color = 1;
                        colvectRight = colvectBlack;
                        sProbe(nDark)=3;
                    case 4
                        color = 2;
                        colvectRight = colvectRed2;
                    case 5
                        color = 2;
                        colvectRight = colvectGreen2;
                    otherwise
                        color = 2;
                        colvectRight = colvectBlack;
                end
                Screen('DrawDots', w, xymatrixRight, s, colvectRight, centerRight,0); 
                ifFlash = 0;
            end

            %中央点颜色变暗
            if (ifDark == 1)           
                if (color == 1) %红色变暗
                    red1 = zeros(3,ndots); 
                    red1(1,:) = 120; 
                    colvectRed1 = uint8(round(red1)); 
                    countColorDarkRed1 = countColorDarkRed1 +1;  %时间计数
                    if (countColorDarkRed1 > timeColorDark)  %变暗500ms
                        red1 = zeros(3,ndots);
                        red1(1,:) = 255;
                        colvectRed1 = uint8(round(red1));
                        countColorDarkRed1 = 1;              
                        ifDark = 0;
                    end
                else               
                    green1 = zeros(3,ndots); %绿色变暗
                    green1(2,:) = 60;
                    colvectGreen1 = uint8(round(green1)); 
                    countColorDarkGreen1 = countColorDarkGreen1 +1;    %时间计数
                    if (countColorDarkGreen1 > timeColorDark)  %变暗500ms
                        green1 = zeros(3,ndots);
                        green1(2,:) = 128;
                        colvectGreen1 = uint8(round(green1));
                        countColorDarkGreen1 = 1;              
                        ifDark = 0;
                    end
                end
            end

            %画注视点
            Screen('FillOval', w, uint8(white), fix_cord);  
            %画中央红绿点
            Screen('DrawDots', w, xymatrixRed1, s, colvectRed1, centerLeft,0);  
            Screen('DrawDots', w, xymatrixGreen1, s, colvectGreen1, centerLeft,0);          
            Screen('DrawingFinished', w); 
            vbl = Screen('Flip', w , vbl + 0.5*ifi);

            %变暗时刻
            if countColorDarkGreen1 == 2               
                sSec(nDark) = 2;
                sPart(nDark) = j;
                tDark(nDark) = GetSecs - start;
                nDark = nDark+1;
                nPress = 1;
            end

            %检测按键
            while  GetSecs - tempT <= 0.1
                [keyIsDown, secs, keyCode] = KbCheck;
                 assert(~keyCode(KbName('Escape')),onExit);
                if keyCode(responseKey)
                    if  secs-pressT > 0.3 && tDark(nDark-1)~=0      %排除连续按键
                        tPress(nDark-1,nPress) = secs - start;           %按键时刻
                        tRTs(nDark-1) = tPress(nDark-1,1) - tDark(nDark-1);     %反应时=按键时刻-变暗时刻
                        nPress = nPress+1;
                        pressT = secs; 
                    end                
                end
            end  

        end;    
        %指导语end1
        if j == 1 
            endtime = endtime1;
        else
            endtime = endtime2;
        end
        img = imread(picEnd{j});
        textureIndex = Screen('MakeTexture', w, img);
        Screen('DrawTexture',w, textureIndex);
        vbl=Screen('Flip', w);               %初始刷一次屏幕
        tempT_ = GetSecs;
        while  GetSecs - tempT_ <= endtime
                [keyIsDown, secs, keyCode] = KbCheck;
                 assert(~keyCode(KbName('Escape')),onExit);
        end
    end
    
    Priority(0);
    ShowCursor
    Screen('CloseAll');
catch
    Priority(0);
    ShowCursor
    Screen('CloseAll');
end
save(['ResultFBA_',ID,'_',datestr(now,30)]);
Screen('CloseAll');    %把所有窗口都关闭
ShowCursor;            %显示鼠标



