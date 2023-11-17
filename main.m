should_train = true;
ObsInfo = rlNumericSpec([15 1]);
ObsInfo.Name = "Blackjack State Vector";
ObsInfo.Description = "Number of 1s, ..., 10s, sum, dealer, ace, bet, stake, gamestate";

ActInfo = rlFiniteSetSpec([1, 2, 3]);
ActInfo.Description = "Bet size [5(1), 20(2), 100(3)] or Hit/Stand [1,2]";

env = rlFunctionEnv(ObsInfo,ActInfo,"stepFunction","resetFunction");

if should_train==true
    agentOpts = rlDQNAgentOptions(...
        UseDoubleDQN = false, ...    
        TargetSmoothFactor = 1, ...
        TargetUpdateFrequency = 4, ...
        DiscountFactor=0.99, ...
        MiniBatchSize = 128);
    
    agentOpts.CriticOptimizerOptions.Algorithm = "adam";
    agentOpts.CriticOptimizerOptions.LearnRate = 1e-4;
    agentOpts.EpsilonGreedyExploration.Epsilon = 1;
    agentOpts.EpsilonGreedyExploration.EpsilonDecay = 1e-4;
    agentOpts.EpsilonGreedyExploration.EpsilonMin = 0.01;
    agentOpts.ExperienceBufferLength = 1e6;
    
    initOpts = rlAgentInitializationOptions(NumHiddenUnit = 256);
    
    DQNagent = rlDQNAgent(ObsInfo, ActInfo, initOpts, agentOpts);
    
    evaluator = rlEvaluator( ...
        EvaluationFrequency=100, ...
        EvaluationStatisticType="MeanEpisodeReward", ...
        NumEpisodes=25, ...
        RandomSeeds=0:24);
    
    MaxEpisodes = 50000;
    trainOpts = rlTrainingOptions(...
        MaxEpisodes = MaxEpisodes, ...
        Verbose = false, ...
        ScoreAveragingWindowLength=20, ...
        StopTrainingCriteria="none", ...
        SaveAgentCriteria="EvaluationStatistic", ...
        SaveAgentValue=9);
    
    % load("savedAgents/Agent82000.mat")
    % savedAgentResult.TrainingOptions.MaxEpisodes = 100000;
    % trainOpts = savedAgentResult.TrainingOptions;


    trainingStats = train(DQNagent,env,trainOpts, Evaluator=evaluator);
else
    load("savedAgents/Agent82000.mat")
    num_steps = 10000;
    rewards = zeros(num_steps,1);
    simOptions = rlSimulationOptions(MaxSteps=500);
    h = animatedline;
    for i = 1:num_steps
        experience = sim(env,saved_agent,simOptions);
        rewards(i) = experience.Reward.Data(2);
        addpoints(h,i,sum(rewards));
        drawnow;
    end
end

