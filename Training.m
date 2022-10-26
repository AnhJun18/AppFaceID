function Training
    clc
    % get the folder contents
    folderName = 'DataCollect';
    if exist(folderName, 'dir')
        d = dir(folderName);
        % remove all files (isdir property is 0)
        dfolders = d([d(:).isdir]);
        % remove '.' and '..' 
        dfolders = dfolders(~ismember({dfolders(:).name},{'.','..'}));
        sizeDfolders=size(dfolders);
        totalObject=sizeDfolders(1,1);
        clc;
        g = alexnet;
        layers = g.Layers;
        layers(23)= fullyConnectedLayer(totalObject);
        layers(25) = classificationLayer;
        allImages= imageDatastore('DataCollect','IncludeSubfolders',true,'LabelSource','foldernames');
        opts = trainingOptions('sgdm','InitialLearnRate',0.001,'MaxEpochs',20,'MiniBatchSize',64);
        myNet1= trainNetwork(allImages,layers,opts);
        save myNet1;
    else 
        warndlg('No training data available');
    end
end