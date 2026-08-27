clear;

words = {   'bath'	'bass'	'path'	'couch'
'beak'	'beet'	'sneak'	'map'
'bear'	'base'	'pear'	'jet'
'boot'	'boom'	'suit'	'fox'
'cage'	'cave'	'gauge'	'hip'
'coat'	'cone'	'vote'	'ram'
'crown'	'crowd'	'drown'	'soup'
'dent'	'desk'	'tent'	'brush'
'gum'	'gut'	'drum'	'whale'
'hole'	'hose'	'goal'	'cap'
'horn'	'horse'	'corn'	'bib'
'lab'	'lamb'	'crab'	'tire'
'lips'	'list'	'chips'	'tape'
'mouse'	'mouth'	'house'	'chain'
'mug'	'mud'	'pug'	'cool'
'night'	'knife'	'bite'	'jar'
'pick'	'pit'	'kick'	'deer'
'porch'	'port'	'torch'	'milk'
'rip'	'rib'	'ship'	'dog'
'rose'	'robe'	'nose'	'pool'
'sick'	'sip'	'wick'	'door'
'sock'	'sod'	'dock'	'lap'
'throne'	'throat'	'crone'	'dish'
'trap'	'trash'	'nap'	'fist'
'tug'	'tub'	'rug'	'mic'
'type'	'tile'	'pipe'	'coach'
'wheat'	'wheel'	'seat'	'gem'
'wig'	'wind'	'fig'	'buzz'
'yarn'	'yard'	'barn'	'safe'
'zit'	'zip'	'sit'	'coal'
'batter'	'baggage'	'ladder'	'peacock'
'berry'	'barrel'	'fairy'	'rapids'
'carrot'	'carriage'	'parrot'	'tadpole'
'cavern'	'cashew'	'tavern'	'banner'
'coffee'	'coffin'	'toffee'	'knuckle'
'dollar'	'dolphin'	'collar'	'hammock'
'letter'	'lettuce'	'sweater'	'cannon'
'money'	'mother'	'honey'	'beagle'
'mountain'	'mousetrap'	'fountain'	'target'
'mustard'	'mustache'	'custard'	'penguin'
'paddle'	'package'	'saddle'	'monkey'
'pickle'	'picture'	'nickel'	'donkey'
'rocket'	'rocker'	'pocket'	'bubble'
'sandal'	'sandwich'	'candle'	'building'
'socket'	'soccer'	'locket'	'filling'
'tailor'	'table'	'sailor'	'candy'
'tower'	'towel'	'shower'	'hamster'
'turtle'	'turkey'	'hurdle'	'banjo'
'wizard'	'whistle'	'lizard'	'bottle'
'dragon'	'dragster'	'wagon'	'peanut'
'funnel'	'fungus'	'tunnel'	'blanket'
'hockey'	'hotdog'	'jockey'	'campus'
'windmill'	'window'	'treadmill'	'badger'
'robber'	'robin'	'bobber'	'necklace'
'magnet'	'magic'	'bonnet'	'camera'
'powder'	'power'	'chowder'	'billboard'
'pillow'	'pillar'	'willow'	'sunrise'
'beaver'	'beehive'	'cleaver'	'children'
'castle'	'cabin'	'tassel'	'water'
'butter'	'button'	'putter'	'camel'
};

numItems = size(words,1);
numBlocks = 1;  %we only go through all items in all (T, C, R, U) target
                %conditions one time - then we'll include the "fifth
                %season" round.

         
portorders = [1 2 3 4
              1 2 4 3
              1 3 2 4
              1 3 4 2
              1 4 3 2
              1 4 2 3
              2 1 3 4
              2 1 4 3
              2 3 1 4
              2 3 4 1
              2 4 1 3
              2 4 3 1
              3 1 2 4
              3 1 4 2
              3 2 1 4
              3 2 4 1
              3 4 1 2
              3 4 2 1
              4 1 2 3 
              4 1 3 2
              4 2 1 3
              4 2 3 1
              4 3 1 2
              4 3 2 1];
          
         


for sub = 1:40   % 1:number of subjects
    for day = 1
  
        %construct set of protorders by trialtype
        portorderlist = cell(4,1);
        for p = 1:4
            portorderlist{p,1} = portorders(randperm(24),:);
        end


        trials = {};
        for b = 1:numBlocks
            for i = 1:numItems
                for t = 1:4
                    line = cell(1,12);
                    line{1,1} = words{i,t};  %targetword
                    pics  = words(i,1:4);

                    switch t
                        case 1
                            tt = 'TCRU';
                            ttn = 1;
                            codes = {'T','C','R','U'};
                        case 2
                            tt = 'TCUU';
                            codes = {'C','T','U2','U'};
                            ttn = 2;
                        case 3
                            tt = 'TRUU';
                            codes = {'R','U2','T','U'};
                            ttn = 3;
                        case 4
                            tt = 'TUUU';
                            codes = {'U','U2','U3','T'};
                            ttn = 4;
                    end

                    sortorderlist = portorderlist{ttn,1};
                    sortorder = sortorderlist(1,:);
                    sortorderlist = sortorderlist(2:size(sortorderlist,1),:);
                    if size(sortorderlist,1) == 0
                        sortorderlist = portorders(randperm(24),:);
                    end
                    portorderlist{ttn,1} = sortorderlist;

                    pics = pics(1,sortorder);
                    codes = codes(1,sortorder);

                    line{1,2} = tt;
                    line(1,3:6) = pics;
                    line(1,7:10) = codes;
                    line{1,11} = strcat(num2str(sortorder(1)),'-',num2str(sortorder(2)),'-',num2str(sortorder(3)),'-',num2str(sortorder(4)));
                    line{1,12} = b;

                    trials = [trials; line];
                end %t
            end %i
        end %b


        %now create the fifth season (60 extra trials with each item type
        %randomly assigned to TCRU, TCUU, TRUU, TUUU such that 15 of each trial
        %type occur)

        type = [1 2 3 4];
        type = repelem(type, 15);
        type = type(randperm(size(type,2)));

        b = 2; % so we can track if items are 5th season (2) or balanced (1) - just in case

        for i = 1:numItems
            t = type(i);
            line = cell(1,12);
            line{1,1} = words{i,t};  %targetword
            pics  = words(i,1:4);

            switch t
                case 1
                    tt = 'TCRU';
                    ttn = 1;
                    codes = {'T','C','R','U'};
                case 2
                    tt = 'TCUU';
                    codes = {'C','T','U2','U'};
                    ttn = 2;
                case 3
                    tt = 'TRUU';
                    codes = {'R','U2','T','U'};
                    ttn = 3;
                case 4
                    tt = 'TUUU';
                    codes = {'U','U2','U3','T'};
                    ttn = 4;
            end

            sortorderlist = portorderlist{ttn,1};
            sortorder = sortorderlist(1,:);
            sortorderlist = sortorderlist(2:size(sortorderlist,1),:);
            if size(sortorderlist,1) == 0
                sortorderlist = portorders(randperm(24),:);
            end
            portorderlist{ttn,1} = sortorderlist;

            pics = pics(1,sortorder);
            codes = codes(1,sortorder);

            line{1,2} = tt;
            line(1,3:6) = pics;
            line(1,7:10) = codes;
            line{1,11} = strcat(num2str(sortorder(1)),'-',num2str(sortorder(2)),'-',num2str(sortorder(3)),'-',num2str(sortorder(4)));
            line{1,12} = b;

            trials = [trials; line];
        end

        trials = trials(randperm(size(trials,1)),:);

        file = fopen(strcat('Sub',num2str(sub),'D',num2str(day),'.dat'),'w');

        fprintf(file,'$targetword\t');
        fprintf(file,'$soundfile\t');
        fprintf(file,'$trialtype\t');
        fprintf(file,'$tlpic\t');
        fprintf(file,'$trpic\t');
        fprintf(file,'$blpic\t');
        fprintf(file,'$brpic\t');
        fprintf(file,'$tlobj\t');
        fprintf(file,'$trobj\t');
        fprintf(file,'$blobj\t');
        fprintf(file,'$brobj\t');
        fprintf(file,'$tlcode\t');
        fprintf(file,'$trcode\t');
        fprintf(file,'$blcode\t');
        fprintf(file,'$brcode\t');
        %fprintf(file,'$portOrder\t');
        fprintf(file,'season\t');
        fprintf(file,'subject\t');
        fprintf(file,'trial\n');

        for t = 1:size(trials,1)
            fprintf(file,'%s\t',trials{t,1});  %target word
            fprintf(file,'%s.wav\t',trials{t,1}); %sound file
            fprintf(file,'%s\t',trials{t,2}); %trial type
            fprintf(file,'%s.jpg\t',trials{t,3}); %tlpic
            fprintf(file,'%s.jpg\t',trials{t,4}); %trpic
            fprintf(file,'%s.jpg\t',trials{t,5}); %blpic
            fprintf(file,'%s.jpg\t',trials{t,6}); %brpic
            fprintf(file,'%s\t',trials{t,3}); %tlobj
            fprintf(file,'%s\t',trials{t,4}); %trobj
            fprintf(file,'%s\t',trials{t,5}); %blobj
            fprintf(file,'%s\t',trials{t,6}); %brobj
            fprintf(file,'%s\t',trials{t,7}); %tlcode
            fprintf(file,'%s\t',trials{t,8}); %trcode
            fprintf(file,'%s\t',trials{t,9}); %blcode
            fprintf(file,'%s\t',trials{t,10}); %brcode
            %fprintf(file,'%s\t',trials{t,11}); %port order
            fprintf(file,'%s\t',num2str(trials{t,12})); %season (1 = regular, 2 = fifth season)
            fprintf(file,'%s\t',num2str(sub)); %subject
            fprintf(file,'%s\n',num2str(t)); %trial number
        end
        fclose(file);
    end
end