clear
close all

% analyze raw data or perform simulations (1 to pick, 0 to the other)
rawdat=1; %raw data from the 2019 Thai general election
simmu=0; %election data will be created from simulations

%%
if rawdat
    simn=1;
elseif simmu
    simn=10000;
end

represultstab=[];
for j=1:simn
    if rawdat
        %% raw data
        load('edatatab.mat')
        numrep=150;
        numparty=size(edata,1);
    elseif simmu
        %% simulations
        numrep=round((200-100).*rand(1,1) + 100);
        numparty=round((100-10).*rand(1,1) + 10);
        numpop=round((1e8-1e6).*rand(1,1) + 1e6);
        rng('shuffle')
        lowerlim=(0.5-0.2).*rand(1,1)+0.2;
        edatarand=sort((1-lowerlim).*rand(1,numparty)+lowerlim);
        edata=[];
        edata(1)=edatarand(1);
        for k=2:numparty
            edata(k,1)=edatarand(k)*(1-sum(edata(1:k-1,1)));
        end
        edata=round(sort(edata,'descend')*numpop);
        
        if mod(j,10)==0
            fprintf('%1.0i ', j)
            if mod(j,100)==0
                fprintf('\n')
            end
        end
        
    end
    
    %% 1. D'hondt
    dhondtqt=[];
    for i=1:numrep
        dhondtqt(:,i)=edata(:,1)/i; %quotient
    end
    dhondtsort=sort(reshape(dhondtqt,[],1),'descend');
    dhondtcutoffqt=dhondtsort(numrep);
    dhondtrep=[];
    for i=1:numparty
        dhondtrep(i,1)=sum(dhondtqt(i,:)>=dhondtcutoffqt);
    end
    if sum(dhondtrep)~= numrep
        disp('Dhondt error')
        return
    end
    
    %% 2. Webster
    websterqt=[];
    for i=1:numrep
        denom=i*2-1;
        websterqt(:,i)=edata(:,1)/denom; %quotient
    end
    webstersort=sort(reshape(websterqt,[],1),'descend');
    webstercutoffqt=webstersort(numrep);
    websterrep=[];
    for i=1:numparty
        websterrep(i,1)=sum(websterqt(i,:)>=webstercutoffqt);
    end
    if sum(websterrep)~= numrep
        disp('Webster error')
        return
    end
    
    %% 3. Hare–Niemeyer method (w/ Hare quota)
    hnhareqt=sum(edata,1)/numrep; %quota
    hnharetab=edata./hnhareqt;
    hnharerep=floor(hnharetab);
    if sum(hnharerep)<numrep
        hnhareremain=hnharetab-hnharerep;
        hnharecutoffnum=numrep-sum(hnharerep);
        hnharesort=sort(hnhareremain,'descend');
        hnharecutoff=hnharesort(hnharecutoffnum);
        hnhareremain(hnhareremain<hnharecutoff)=0;
        hnhareadd=ceil(hnhareremain);
        hnharerep=hnharerep+hnhareadd;
    end
    if sum(hnharerep)~= numrep
        disp(' Hare–Niemeyer method (w/ Hare quota) error')
        return
    end
    
    %% 4. Hare–Niemeyer method (w/ Droop quota)
    hndroopqt=1+sum(edata,1)/(1+numrep); %quota
    hndrooptab=edata./hndroopqt;
    hndrooprep=floor(hndrooptab);
    if sum(hndrooprep)<numrep
        hndroopremain=hndrooptab-hndrooprep;
        hndroopcutoffnum=numrep-sum(hndrooprep);
        hndroopsort=sort(hndroopremain,'descend');
        hnharecutoff=hndroopsort(hndroopcutoffnum);
        hndroopremain(hndroopremain<hnharecutoff)=0;
        hndroopadd=ceil(hndroopremain);
        hndrooprep=hndrooprep+hndroopadd;
    end
    if sum(hndrooprep)~= numrep
        disp(' Hare–Niemeyer method (w/ Droop quota) error')
        return
    end
    
    %% 5. Quota optimization
    
    topg=1.3;bottomg=0.99;qoreptabsumopt=1;intv=1;
    
    while min(qoreptabsumopt~=0)
        qoqtguessi=ceil(sum(edata,1)/(numrep*topg)); %quota initial guess
        qoqtguessf=floor(sum(edata,1)/(numrep*bottomg)); %quota final guess
        
        qoqtguesstab=repelem(qoqtguessi:intv:qoqtguessf,numparty,1);
        qotab=repelem(edata,1,size(qoqtguesstab,2));
        qoreptab=floor(qotab./qoqtguesstab);
        qoreptabsum=sum(qoreptab,1);
        qoreptabsumopt=abs(qoreptabsum-numrep);      
        topg=topg+0.05;
        bottomg=bottomg-0.005;
        intv=intv-0.01;
    end
    
    if rawdat
        figure
        plot(qoqtguesstab(1,:),qoreptabsumopt,'k','linewidth',1.2)
        xlabel('Quota')
        ylabel('|\Sigman_E - n_S|')
        set(gca,'fontsize',14,'linewidth',1.2,'tickdir','out','ticklength',[0.015,0.015])
        xlim([qoqtguessi qoqtguessf])
        xlim([55000 70000])
        set(gcf,'windowstyle','normal')
        set(gcf,'resize','off')
    end
    
    qoqtoptf=qoqtguesstab(1,find(qoreptabsumopt==0,1,'first'));
    qoqtoptl=qoqtguesstab(1,find(qoreptabsumopt==0,1,'last'));
    qorep=qoreptab(:,find(qoreptabsumopt==0,1,'first'));
    
    if sum(qorep)~= numrep
        disp(' Quota optimization error')
        return
    end
    
    
    %% Results
    
    represults=[edata./(sum(edata)/numrep) edata./sum(edata)*100 dhondtrep websterrep hnharerep hndrooprep qorep];
    represultstab(end+1:end+numparty,1:7)=represults;
%     figure
%     plot(represults(:,1),represults(:,2:end),'.','MarkerSize',15); hold on
%     plot([0 max(max(represults))+10],[0 max(max(represults))+10],'r-')
    
end
if simmu
    alloelecanalyze
end