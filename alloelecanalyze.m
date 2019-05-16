% close all
cc=lines(25);ii=1;

leglabel={'(1),(5)' , '(2)' , '(3)' , '(4)','(5)'};
for r=3:7
    figure
    plot(represultstab(:,2),represultstab(:,r)./represultstab(:,1),'.','MarkerSize',2,'markeredgecolor',cc(ii,:)); hold on
    plot([0 60],[1 1],'k','linewidth',0.75); hold on
    xlabel('Party popular vote (%)')
    ylabel('n_E / n_P')
    set(gca,'fontsize',14,'linewidth',1.2,'tickdir','out','ticklength',[0.015,0.015],'yminortick','on')
    set(gcf,'windowstyle','normal')
    set(gcf,'resize','off')
    % grid on
    ylim([0.5 2])
    xlim([0 50])
    ii=ii+1;
    legend on
    legend(leglabel(r-2))
    legend boxoff 
end

%% histogram all
histedg=0.1:0.01:10;
historeptab=[];
% historeptab5=[];represultstab5=represultstab(represultstab(:,2)<5,:);
% historeptabh5=[];represultstabh5=represultstab(represultstab(:,2)>5,:);
for m=3:7
    figure(10)
    historep=histc(represultstab(:,m)./represultstab(:,1),histedg);
    stairs(histedg,historep,'linewidth',1.5); hold on
    historeptab(:,end+1)=historep;
end
figure(10)
xlabel('n_E / n_P')
ylabel('Occurrence')
xlim([0.5 2])
set(gca,'fontsize',14,'linewidth',1.2,'tickdir','out','ticklength',[0.015,0.015])
set(gcf,'windowstyle','normal')
set(gcf,'resize','off')
legend on
legend('(1),(5)','(2)','(3)','(4)','(5)')

for p=size(historeptab,1):-1:1
    if historeptab(p,1)>0
        for q=p-1:-1:1
            if historeptab(q,1)>historeptab(q,3)
                inloc=q+1;
                break
            end
        end
        break
    end
end
inhnharedhond=sum(historeptab(inloc:end,3)-historeptab(inloc:end,1));
inhnharedhondperc=inhnharedhond/sum(historeptab(:,3));

%% histogram lower than 5%
histedg=0.1:0.02:10;
historeptab=[];
historeptab5=[];represultstab5=represultstab(represultstab(:,2)<5&represultstab(:,1)>0,:);
stattab=[];
% historeptabh5=[];represultstabh5=represultstab(represultstab(:,2)>5,:);
for m=3:7
    figure(11)
    nepernp5=represultstab5(:,m)./represultstab5(:,1);
    historep5=histc(nepernp5,histedg);
    stairs(histedg,historep5,'linewidth',1.5); hold on
    historeptab5(:,end+1)=historep5;
    stattab(m-2,1)=mode(nepernp5(nepernp5>0));
    stattab(m-2,2)=std(nepernp5(nepernp5>0));
    stattab(m-2,3)=skewness(nepernp5(nepernp5>0));
%     [h,p]=adtest(nepernp5(nepernp5>0))
end
figure(11)
xlabel('n_E / n_P')
ylabel('Occurrence')
xlim([0.5 2])
set(gca,'fontsize',14,'linewidth',1.2,'tickdir','out','ticklength',[0.015,0.015])
set(gcf,'windowstyle','normal')
set(gcf,'resize','off')
legend on
legend('(1),(5)','(2)','(3)','(4)','(5)')

inhnharedhond5=sum(historeptab5(histedg>1,3)-historeptab5(histedg>1,1));
inhnharedhondperc5=inhnharedhond5/sum(historeptab5(:,3));
lowestper=1/histedg(find(historeptab5(:,3)>0,1,'last'));
fprintf('Area[(3)-(1)]above1=%2.1fpercent lowestnPtogetelected=%1.4f\n',inhnharedhondperc5*100,lowestper)

%% histogram higher than 5%
histedgh5=0.1:0.005:10;
% historeptab=[];
% historeptab5=[];represultstab5=represultstab(represultstab(:,2)<5,:);
historeptabh5=[];represultstabh5=represultstab(represultstab(:,2)>5&represultstab(:,1)>0,:);
for m=3:7
    figure(12)
    nepernph5=represultstabh5(:,m)./represultstabh5(:,1);
    historeph5=histc(nepernph5,histedgh5);
    stairs(histedgh5,historeph5,'linewidth',1.5); hold on
    historeptabh5(:,end+1)=historeph5;
    stattab(m-2,4)=mode(nepernph5(nepernph5>0));
    stattab(m-2,5)=std(nepernph5(nepernph5>0));
    stattab(m-2,6)=skewness(nepernph5(nepernph5>0));
%     [h,p]=adtest(nepernph5(nepernph5>0),'distribution','weibull')
%     median(nepernph5(nepernph5>0))
%     normplot(nepernph5(nepernph5>0))
end
figure(12)
xlabel('n_E / n_P')
ylabel('Occurrence')
xlim([0.8 1.2])
set(gca,'fontsize',14,'linewidth',1.2,'tickdir','out','ticklength',[0.015,0.015])
set(gcf,'windowstyle','normal')
set(gcf,'resize','off')
legend on
legend('(1),(5)','(2)','(3)','(4)','(5)')


figure
plot(represultstab(:,2),represultstab(:,3)./represultstab(:,1),'k+','MarkerSize',1); hold on
plot(represultstab(:,2),represultstab(:,5)./represultstab(:,1),'rx','MarkerSize',1); hold on
plot([0 60],[1 1],'k','linewidth',0.75); hold on
xlabel('Party popular vote (%)')
ylabel('n_E / n_P')
set(gca,'fontsize',14,'linewidth',1.2,'tickdir','out','ticklength',[0.015,0.015],'yminortick','on')
set(gcf,'windowstyle','normal')
set(gcf,'resize','off')
% grid on
ylim([0.5 2])
xlim([0 50])

save('outputXXX.mat')