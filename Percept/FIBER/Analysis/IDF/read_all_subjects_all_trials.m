function [] =  read_all_subjects_all_trials

default_path = '/Users/marsman/Documents/Experiments/070115_houses_versus_faces/Eyetracker data/';
fprintf('STEP 1: reading in all data files.\n');

%subject 1, run 1
fprintf('reading subject 1, run 1...\n');
subject1_run1 = readIDFevents_by_message([default_path 'subject1/events/subject1_trial1_lastdataset.txt']);

%subject 1, run 2
fprintf('reading subject 1, run 2...\n');
subject1_run2 = readIDFevents_by_message([default_path 'subject1/events/subject1_trial2_lastdataset.txt']);

%subject 2, run 1
fprintf('reading subject 2, run 1...\n');
subject2_run1 = readIDFevents_by_message([default_path 'subject2/events/subject2_trial1.txt']);

%subject 2, run 2
fprintf('reading subject 2, run 2...\n');
subject2_run2 = readIDFevents_by_message([default_path 'subject2/events/subject2_trial2.txt']);

%subject 3, run 1
fprintf('reading subject 3, run 1...\n');
subject3_run1 = readIDFevents_by_message([default_path 'subject3/events/subject3_trial1.txt']);
%subject 3, run 2
fprintf('reading subject 3, run 2...\n');
subject3_run2 = readIDFevents_by_message([default_path 'subject3/events/subject3_trial2.txt']);

%subject 4, run 1
fprintf('reading subject 4, run 1...\n');
subject4_run1 = readIDFevents_by_message([default_path 'subject4/events/subject4_trial1.txt']);

%subject 1, run 2
fprintf('reading subject 4, run 2...\n');
subject4_run2 = readIDFevents_by_message([default_path 'subject4/events/subject4_trial2.txt']);

subject1_run1_offset = 60; %% localiser are at beginning
subject1_run2_offset = 3; 
subject2_run1_offset = 3;
subject2_run2_offset = 3;
subject3_run1_offset = 3;
subject3_run2_offset = 3;
subject4_run1_offset = 3;
subject4_run2_offset = 3;

fprintf('STEP 2: calculating hit data.\n');

subject1_run1 = hit_test(subject1_run1, 1, subject1_run1_offset);
subject1_run2 = hit_test(subject1_run2, 2, subject1_run2_offset);

subject2_run1 = hit_test(subject2_run1, 1, subject2_run1_offset);
subject2_run2 = hit_test(subject2_run2, 2, subject2_run2_offset);

subject3_run1 = hit_test(subject3_run1, 1, subject3_run1_offset);
subject3_run2 = hit_test(subject3_run2, 2, subject3_run2_offset);

subject4_run1 = hit_test(subject4_run1, 1, subject4_run1_offset);
subject4_run2 = hit_test(subject4_run2, 2, subject4_run2_offset);

fprintf('STEP 3: house or face check, in correspondence with given task inside scanner.\n');

plotting = 0; exporting = 1;
previous_fixation = 1;
fixation_duration = 0;


if (previous_fixation)
 [ subject1_run1 s1_file1] = house_or_face_check_with_previous_fixation( subject1_run1, subject1_run1_offset, 1, plotting, exporting);
 [ subject1_run2 s1_file2] = house_or_face_check_with_previous_fixation( subject1_run2, subject1_run2_offset, 2, plotting, exporting);

 [ subject2_run1 s2_file1] = house_or_face_check_with_previous_fixation( subject2_run1, subject2_run1_offset, 1, plotting, exporting);
 [ subject2_run2 s2_file2] = house_or_face_check_with_previous_fixation( subject2_run2, subject2_run2_offset, 2, plotting, exporting);

 [ subject3_run1 s3_file1] = house_or_face_check_with_previous_fixation( subject3_run1, subject3_run1_offset, 1, plotting, exporting);
 [ subject3_run2 s3_file2] = house_or_face_check_with_previous_fixation( subject3_run2, subject3_run2_offset, 2, plotting, exporting);

 [ subject4_run1 s4_file1] = house_or_face_check_with_previous_fixation( subject4_run1, subject4_run1_offset, 1, plotting, exporting);
 [ subject4_run2 s4_file2] = house_or_face_check_with_previous_fixation( subject4_run2, subject4_run2_offset, 2, plotting, exporting);

elseif(fixation duration)
 threshold = 250;
 [ subject1_run1 s1_file1] = house_or_face_check_with_fixation_duration( subject1_run1, subject1_run1_offset, 1, plotting, exporting, threshold);
 [ subject1_run2 s1_file2] = house_or_face_check_with_fixation_duration( subject1_run2, subject1_run2_offset, 2, plotting, exporting, threshold);

 [ subject2_run1 s2_file1] = house_or_face_check_with_fixation_duration( subject2_run1, subject2_run1_offset, 1, plotting, exporting, threshold);
 [ subject2_run2 s2_file2] = house_or_face_check_with_fixation_duration( subject2_run2, subject2_run2_offset, 2, plotting, exporting, threshold);

 [ subject3_run1 s3_file1] = house_or_face_check_with_fixation_duration( subject3_run1, subject3_run1_offset, 1, plotting, exporting, threshold);
 [ subject3_run2 s3_file2] = house_or_face_check_with_fixation_duration( subject3_run2, subject3_run2_offset, 2, plotting, exporting, threshold);

 [ subject4_run1 s4_file1] = house_or_face_check_with_fixation_duration( subject4_run1, subject4_run1_offset, 1, plotting, exporting, threshold);
 [ subject4_run2 s4_file2] = house_or_face_check_with_fixation_duration( subject4_run2, subject4_run2_offset, 2, plotting, exporting, threshold);
else
    
 [ subject1_run1 s1_file1] = house_or_face_check( subject1_run1, subject1_run1_offset, 1, plotting, exporting);
 [ subject1_run2 s1_file2] = house_or_face_check( subject1_run2, subject1_run2_offset, 2, plotting, exporting);

 [ subject2_run1 s2_file1] = house_or_face_check( subject2_run1, subject2_run1_offset, 1, plotting, exporting);
 [ subject2_run2 s2_file2] = house_or_face_check( subject2_run2, subject2_run2_offset, 2, plotting, exporting);

 [ subject3_run1 s3_file1] = house_or_face_check( subject3_run1, subject3_run1_offset, 1, plotting, exporting);
 [ subject3_run2 s3_file2] = house_or_face_check( subject3_run2, subject3_run2_offset, 2, plotting, exporting);

 [ subject4_run1 s4_file1] = house_or_face_check( subject4_run1, subject4_run1_offset, 1, plotting, exporting);
 [ subject4_run2 s4_file2] = house_or_face_check( subject4_run2, subject4_run2_offset, 2, plotting, exporting);

end

assignin('base', 'subject1_run1', subject1_run1);
assignin('base', 'subject1_run2', subject1_run2);

assignin('base', 'subject2_run1', subject2_run1);
assignin('base', 'subject2_run2', subject2_run2);

assignin('base', 'subject3_run1', subject3_run1);
assignin('base', 'subject3_run2', subject3_run2);

assignin('base', 'subject4_run1', subject4_run1);
assignin('base', 'subject4_run2', subject4_run2);

%% create brainvoyager protocol files
s1_prt1 = convertCSVtoPRT(s1_file1, 9, 4, 'BrainVoyager');
s1_prt2 = convertCSVtoPRT(s1_file2, 9, 4, 'BrainVoyager');

s2_prt1 = convertCSVtoPRT(s2_file1, 9, 4, 'BrainVoyager');
s2_prt2 = convertCSVtoPRT(s2_file2, 9, 4, 'BrainVoyager');

s3_prt1 = convertCSVtoPRT(s3_file1, 9, 4, 'BrainVoyager');
s3_prt2 = convertCSVtoPRT(s3_file2, 9, 4, 'BrainVoyager');

s4_prt1 = convertCSVtoPRT(s4_file1, 9, 4, 'BrainVoyager');
s4_prt2 = convertCSVtoPRT(s4_file2, 9, 4, 'BrainVoyager');

fprintf('subject1 trial 1:\t%s\n', s1_prt1);
fprintf('subject1 trial 2:\t%s\n', s1_prt2);
fprintf('subject2 trial 1:\t%s\n', s2_prt1);
fprintf('subject2 trial 2:\t%s\n', s2_prt2);
fprintf('subject3 trial 1:\t%s\n', s3_prt1);
fprintf('subject3 trial 2:\t%s\n', s3_prt2);
fprintf('subject4 trial 1:\t%s\n', s4_prt1);
fprintf('subject4 trial 2:\t%s\n', s4_prt2);

return
[s1t1_durations s1t1_pos_avg s1t1_results s1c1 s1ic1] = fixation_analysis(subject1_run1, subject1_run1_offset);
[s1t2_durations s1t2_pos_avg s1t2_results s1c2 s1ic2] = fixation_analysis(subject1_run2, subject1_run2_offset);

[s2t1_durations s2t1_pos_avg s2t1_results s2c1 s2ic1] = fixation_analysis(subject2_run1, subject2_run1_offset);
[s2t2_durations s2t2_pos_avg s2t2_results s2c2 s2ic2] = fixation_analysis(subject2_run2, subject2_run2_offset);

[s3t1_durations s3t1_pos_avg s3t1_results s3c1 s3ic1] = fixation_analysis(subject3_run1, subject3_run1_offset);
[s3t2_durations s3t2_pos_avg s3t2_results s3c2 s3ic2] = fixation_analysis(subject3_run2, subject3_run2_offset);

[s4t1_durations s4t1_pos_avg s4t1_results s4c1 s4ic1] = fixation_analysis(subject4_run1, subject4_run1_offset);
[s4t2_durations s4t2_pos_avg s4t2_results s4c2 s4ic2] = fixation_analysis(subject4_run2, subject4_run2_offset);

%% erase the lines where fixation crosses or free viewing case
clear indx;
[indx,indy]=find(s1c1<0);
s1c1(indx,:) = [];
s1ic1(indx,:) = [];

clear indx;
[indx,indy]=find(s1c2<0);
s1c2(indx,:) = [];
s1ic2(indx,:) = [];

clear indx;
[indx,indy]=find(s2c1<0);
s2c1(indx,:) = [];
s2ic1(indx,:) = [];

clear indx;
[indx,indy]=find(s2c2<0);
s2c2(indx,:) = [];
s2ic2(indx,:) = [];

clear indx;
[indx,indy]=find(s3c1<0);
s3c1(indx,:) = [];
s3ic1(indx,:) = [];

clear indx;
[indx,indy]=find(s3c2<0);
s3c2(indx,:) = [];
s3ic2(indx,:) = [];

clear indx;
[indx,indy]=find(s4c1<0);
s4c1(indx,:) = [];
s4ic1(indx,:) = [];

clear indx;
[indx,indy]=find(s4c2<0);
s4c2(indx,:) = [];
s4ic2(indx,:) = [];


sum_s1c1 = (sum(s1c1, 1) / size(s1c1,1) *100 );
sum_s1c2 = (sum(s1c2, 1) / size(s1c2,1) *100 );
sum_s2c1 = (sum(s2c1, 1) / size(s2c1,1) *100 );
sum_s2c2 = (sum(s2c2, 1) / size(s2c2,1) *100 );
sum_s3c1 = (sum(s3c1, 1) / size(s3c1,1) *100 );
sum_s3c2 = (sum(s3c2, 1) / size(s3c2,1) *100 );
sum_s4c1 = (sum(s4c1, 1) / size(s4c1,1) *100 );
sum_s4c2 = (sum(s4c2, 1) / size(s4c2,1) *100 );

sum_s1ic1 = (sum(s1ic1, 1) / size(s1ic1,1) *100 );
sum_s1ic2 = (sum(s1ic2, 1) / size(s1ic2,1) *100 );
sum_s2ic1 = (sum(s2ic1, 1) / size(s2ic1,1) *100 );
sum_s2ic2 = (sum(s2ic2, 1) / size(s2ic2,1) *100 );
sum_s3ic1 = (sum(s3ic1, 1) / size(s3ic1,1) *100 );
sum_s3ic2 = (sum(s3ic2, 1) / size(s3ic2,1) *100 );
sum_s4ic1 = (sum(s4ic1, 1) / size(s4ic1,1) *100 );
sum_s4ic2 = (sum(s4ic2, 1) / size(s4ic2,1) *100 );

instruction_correct_sum =   sum_s1c1(1:20) + sum_s1c2(1:20) + ...
                            sum_s2c1(1:20) + sum_s2c2(1:20) + ...
                            sum_s4c1(1:20) + sum_s3c2(1:20) + ...
                            sum_s4c1(1:20) + sum_s4c2(1:20);

instruction_incorrect_sum = sum_s1ic1(1:20) + sum_s1ic2(1:20) + ...
                            sum_s2ic1(1:20) + sum_s2ic2(1:20) + ...
                            sum_s4ic1(1:20) + sum_s3ic2(1:20) + ...
                            sum_s4ic1(1:20) + sum_s4ic2(1:20);

figure
plot(instruction_correct_sum / 8);
ylim([0 100])
figure;
plot(instruction_incorrect_sum / 8);
ylim([0 100])


for i = 0:3
    for j = 1:5
        rowcorrect1(i+1, j) = sum( s1c1( (i*5)+ j, 1:20));
        rowcorrect2(i+1, j) = sum( s1c2( (i*5)+ j, 1:20));
        rowcorrect3(i+1, j) = sum( s2c1( (i*5)+ j, 1:20));
        rowcorrect4(i+1, j) = sum( s2c2( (i*5)+ j, 1:20));
        rowcorrect5(i+1, j) = sum( s3c1( (i*5)+ j, 1:20));
        rowcorrect6(i+1, j) = sum( s3c2( (i*5)+ j, 1:20));
        rowcorrect7(i+1, j) = sum( s4c1( (i*5)+ j, 1:20));
        rowcorrect8(i+1, j) = sum( s4c2( (i*5)+ j, 1:20));

        rowicorrect1(i+1, j) = sum( s1ic1( (i*5)+ j, 1:20));
        rowicorrect2(i+1, j) = sum( s1ic2( (i*5)+ j, 1:20));
        rowicorrect3(i+1, j) = sum( s2ic1( (i*5)+ j, 1:20));
        rowicorrect4(i+1, j) = sum( s2ic2( (i*5)+ j, 1:20));
        rowicorrect5(i+1, j) = sum( s3ic1( (i*5)+ j, 1:20));
        rowicorrect6(i+1, j) = sum( s3ic2( (i*5)+ j, 1:20));
        rowicorrect7(i+1, j) = sum( s4ic1( (i*5)+ j, 1:20));
        rowicorrect8(i+1, j) = sum( s4ic2( (i*5)+ j, 1:20));

    end
end

rowtotal = rowcorrect1 + ...
           rowcorrect2 +...
           rowcorrect3 +...
           rowcorrect4 +...
           rowcorrect5 +...
           rowcorrect6 +...
           rowcorrect7 +...
           rowcorrect8;
rowtotal_incorrect = rowicorrect1 + ...
           rowicorrect2 +...
           rowicorrect3 +...
           rowicorrect4 +...
           rowicorrect5 +...
           rowicorrect6 +...
           rowicorrect7 +...
           rowicorrect8;

       
row_percent = (rowtotal / 8) / 20 * 100;
row_percent_incorrect = (rowtotal_incorrect / 8) / 20 * 100;

figure
for i = 1:4
    subplot(2,2, i);
    bar(row_percent(i,:));
    ylim([0 100]);
end

figure
for i = 1:4
    subplot(2,2, i);
    bar(row_percent_incorrect(i,:));
    ylim([0 100]);
end

       % subplot(2,4,1)
% plot(s1t1_results(1,1:20))
% subplot(2,4,2)
% plot(s1t2_results(1,1:20))
% subplot(2,4,3)
% plot(s2t1_results(1,1:20))
% subplot(2,4,4)
% plot(s2t2_results(1,1:20))
% subplot(2,4,5)
% plot(s3t1_results(1,1:20))
% subplot(2,4,6)
% plot(s3t2_results(1,1:20))
% subplot(2,4,7)
% plot(s4t1_results(1,1:20))
% subplot(2,4,8)
% plot(s4t2_results(1,1:20))
title('look at houses');

%%create averages for each condition
houses_class_avg =( s1t1_results(1,1:20) + ...
                    s1t2_results(1,1:20) + ...
                    s2t1_results(1,1:20) + ...
                    s2t2_results(1,1:20) + ...
                    s3t1_results(1,1:20) + ...
                    s3t2_results(1,1:20) + ...
                    s4t1_results(1,1:20) + ...
                    s4t2_results(1,1:20) )/ 8;

plot(houses_class_avg);
ylim([250 500]);
figure;
% subplot(2,4,1)
% plot(s1t1_results(2,1:20))
% subplot(2,4,2)
% plot(s1t2_results(2,1:20))
% subplot(2,4,3)
% plot(s2t1_results(2,1:20))
% subplot(2,4,4)
% plot(s2t2_results(2,1:20))
% subplot(2,4,5)
% plot(s3t1_results(2,1:20))
% subplot(2,4,6)
% plot(s3t2_results(2,1:20))
% subplot(2,4,7)
% plot(s4t1_results(2,1:20))
% subplot(2,4,8)
% plot(s4t2_results(2,1:20))
title('look at faces');

faces_class_avg = ( s1t1_results(2,1:20) + ...
                    s1t2_results(2,1:20) + ...
                    s2t1_results(2,1:20) + ...
                    s2t2_results(2,1:20) + ...
                    s3t1_results(2,1:20) + ...
                    s3t2_results(2,1:20) + ...
                    s4t1_results(2,1:20) + ...
                    s4t2_results(2,1:20) )/ 8;

plot(faces_class_avg);
ylim([250 500]);

figure;
% subplot(2,4,1)
% plot(s1t1_results(3,1:20))
% subplot(2,4,2)
% plot(s1t2_results(3,1:20))
% subplot(2,4,3)
% plot(s2t1_results(3,1:20))
% subplot(2,4,4)
% plot(s2t2_results(3,1:20))
% subplot(2,4,5)
% plot(s3t1_results(3,1:20))
% subplot(2,4,6)
% plot(s3t2_results(3,1:20))
% subplot(2,4,7)
% plot(s4t1_results(3,1:20))
% subplot(2,4,8)
% plot(s4t2_results(3,1:20))

title('free viewing');
freev_class_avg = ( s1t1_results(3,1:20) + ...
                    s1t2_results(3,1:20) + ...
                    s2t1_results(3,1:20) + ...
                    s2t2_results(3,1:20) + ...
                    s3t1_results(3,1:20) + ...
                    s3t2_results(3,1:20) + ...
                    s4t1_results(3,1:20) + ...
                    s4t2_results(3,1:20) )/ 8;
plot(freev_class_avg);
ylim([250 500]);
