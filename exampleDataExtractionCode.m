% Define the target animal ID and files to analyze
targetRatID = 'Rat1';
targetFiles = {'TestGroupI.avi', 'TestGroupII.avi'};

% Initialize counters
touchCounts = struct('LeftWall', 0, 'RightWall', 0, 'BothWall', 0, ...
                     'LeftFloor', 0, 'RightFloor', 0);
totalDuration = 0; % in seconds

% Iterate through the DataNested structure
for i = 1:numel(DataNested)
    % Check if the current file is in our target list
    if ismember(DataNested(i).Filename, targetFiles)
        
        % Find the subject matching our target ID
        subIdx = find(strcmp({DataNested(i).Subject.ID}, targetRatID));
        
        if ~isempty(subIdx)
            subjectData = DataNested(i).Subject(subIdx);
            
            % Iterate through all segments for this subject
            for segIdx = 1:numel(subjectData.Segment)
                currentSeg = subjectData.Segment(segIdx);
                
                % Calculate segment duration (Stop Time - Start Time)
                % Note: To calculate metrics for a *single* segment, you can 
                % replace this loop by indexing a specific segIdx (e.g., segIdx = 1)
                segDuration = currentSeg.TimeRange(2) - currentSeg.TimeRange(1);
                totalDuration = totalDuration + segDuration;
                
                % Tally the touches within this segment
                for tIdx = 1:numel(currentSeg.Touch)
                    touchType = currentSeg.Touch(tIdx).Touch;
                    
                    switch touchType
                        case 'Left Wall'
                            touchCounts.LeftWall = touchCounts.LeftWall + 1;
                        case 'Right Wall'
                            touchCounts.RightWall = touchCounts.RightWall + 1;
                        case 'Both Wall'
                            touchCounts.BothWall = touchCounts.BothWall + 1;
                        case 'Left Floor'
                            touchCounts.LeftFloor = touchCounts.LeftFloor + 1;
                        case 'Right Floor'
                            touchCounts.RightFloor = touchCounts.RightFloor + 1;
                    end
                end
            end
        end
    end
end

% Calculate Key Metrics
totalWallTouches = touchCounts.LeftWall + touchCounts.RightWall + touchCounts.BothWall;

% Asymmetry Index: (Right - Left) / Total Wall Touches
if totalWallTouches > 0
    asymmetryIndex = (touchCounts.RightWall - touchCounts.LeftWall) / totalWallTouches;
else
    asymmetryIndex = NaN; % Prevent division by zero if no wall touches occurred
end

% Touch Rate: Total Wall Touches per minute
touchRatePerMin = totalWallTouches / (totalDuration / 60);

% Display Results
fprintf('--- Results for %s ---\n', targetRatID);
fprintf('Total Wall Touches: %d\n', totalWallTouches);
fprintf('Asymmetry Index: %.2f\n', asymmetryIndex);
fprintf('Total Time in Cylinder: %.1f seconds\n', totalDuration);
fprintf('Rate of Wall Touches: %.2f touches/minute\n', touchRatePerMin);

