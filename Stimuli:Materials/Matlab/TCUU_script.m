clear;
rng('shuffle');

% --- DEFINE YOUR STIMULI HERE ---
% words must be 60 x 4 (60 sets, 4 images each)
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

numSets = size(words,1);
assert(size(words,2) == 4, 'words must have 4 columns (4 images per set).');

% all 24 position permutations
portorders = perms(1:4);

nSubs  = 40;
day    = 1;
season = 1;

% TCUU only: auditory target = column 2
tt = 'TCUU';
codes_base = {'C','T','U2','U'};

for sub = 1:nSubs

    permQueue = portorders(randperm(24),:);
    trials = cell(numSets, 12);

    for i = 1:numSets

        targetword = words{i,2};
        pics_raw   = words(i,1:4);

        % next permutation (recycle when empty)
        sortorder = permQueue(1,:);
        permQueue(1,:) = [];
        if isempty(permQueue)
            permQueue = portorders(randperm(24),:);
        end

        pics  = pics_raw(sortorder);
        codes = codes_base(sortorder);

        line = cell(1,12);
        line{1} = targetword;
        line{2} = tt;
        line(3:6)  = pics;
        line(7:10) = codes;
        line{11} = sprintf('%d-%d-%d-%d', sortorder);
        line{12} = season;

        trials(i,:) = line;
    end

    % shuffle trial order
    trials = trials(randperm(numSets),:);

    % write file
    fname = sprintf('Sub%dD%d_TCUU60.dat', sub, day);
    file = fopen(fname,'w');

    fprintf(file,'$targetword\t$soundfile\t$trialtype\t');
    fprintf(file,'$tlpic\t$trpic\t$blpic\t$brpic\t');
    fprintf(file,'$tlobj\t$trobj\t$blobj\t$brobj\t');
    fprintf(file,'$tlcode\t$trcode\t$blcode\t$brcode\t');
    fprintf(file,'season\tsubject\ttrial\n');

    for t = 1:size(trials,1)
        fprintf(file,'%s\t',trials{t,1});
        fprintf(file,'%s.wav\t',trials{t,1});
        fprintf(file,'%s\t',trials{t,2});

        fprintf(file,'%s.jpg\t',trials{t,3});
        fprintf(file,'%s.jpg\t',trials{t,4});
        fprintf(file,'%s.jpg\t',trials{t,5});
        fprintf(file,'%s.jpg\t',trials{t,6});

        fprintf(file,'%s\t',trials{t,3});
        fprintf(file,'%s\t',trials{t,4});
        fprintf(file,'%s\t',trials{t,5});
        fprintf(file,'%s\t',trials{t,6});

        fprintf(file,'%s\t',trials{t,7});
        fprintf(file,'%s\t',trials{t,8});
        fprintf(file,'%s\t',trials{t,9});
        fprintf(file,'%s\t',trials{t,10});

        fprintf(file,'%d\t',trials{t,12});
        fprintf(file,'%d\t',sub);
        fprintf(file,'%d\n',t);
    end

    fclose(file);
end
