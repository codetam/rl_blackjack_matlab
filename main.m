use_player = true;
train_player = true;
if use_player    
    obsInfo = rlNumericSpec([21 1]);
    obsInfo.Name = "Blackjack Player State Vector";
    obsInfo.Description = "Number of 1s out, ..., 10s, number of 1s in player's hand, ..., 10s, dealer_card";

    actInfo = rlFiniteSetSpec([1, 2]);
    actInfo.Description = "Hit/Stand [1,2]";

    env = rlFunctionEnv(obsInfo,actInfo,"stepPlayer","resetPlayer");
    criticNet = [
        featureInputLayer(prod(obsInfo.Dimension))
        fullyConnectedLayer(128)
        reluLayer
        fullyConnectedLayer(64)
        reluLayer
        fullyConnectedLayer(numel(actInfo.Elements))
    ];
    criticNet = dlnetwork(criticNet);
    % summary(criticNet);
    critic = rlVectorQValueFunction(criticNet,obsInfo,actInfo,'UseDevice','gpu');
    criticOpts = rlOptimizerOptions(LearnRate=0.001);

    agentOpts = rlDQNAgentOptions(...
        UseDoubleDQN = false, ...   
        CriticOptimizerOptions=criticOpts,...
        MiniBatchSize = 128, ...
        NumStepsToLookAhead=10, ...
        ExperienceBufferLength = 1e6, ...
        DiscountFactor=0.99);
    
    agent = rlDQNAgent(critic,agentOpts);
    
    % evaluator options
    evaluator = rlEvaluator( ...
        EvaluationStatisticType="MeanEpisodeReward", ...
        NumEpisodes=20, ...
        EvaluationFrequency=100, ...
        RandomSeeds=0:19);

    % training options
    MaxEpisodes = 50000;
    trainOpts = rlTrainingOptions(...
        MaxEpisodes = MaxEpisodes, ...
        MaxStepsPerEpisode=500, ...
        ScoreAveragingWindowLength=50, ...
        Verbose = false, ...
        Plots="training-progress", ...
        SaveAgentCriteria="EpisodeFrequency", ...
        SaveAgentValue=5000);
    % trainOpts.UseParallel = true;
    % trainOpts.ParallelizationOptions.Mode = "async";

    if train_player
        % Train the agent.
        trainingStats = train(agent,env,trainOpts, Evaluator=evaluator);
    else
        rng(0);
        InitialObs = reset(env);
        InitialObs'
        [NextObs,Reward,IsDone,Info] = step(env,1);
        NextObs'
    end
end

