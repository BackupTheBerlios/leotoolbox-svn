function[pictures] = load_bitmaps ( bitmap_path, scaling, recursive )
%
%  loads all stimuli images from the preset directory
%
%  Synopsis : load_bitmaps( path [, scaling parameter] );
%        
%     
%  J.B.C. Marsman, 
%
%  7 - 12 - 2006
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  06/12/2006    Created
%  20/12/2006    Assignin base so no reloading every time is necessary
%  13/04/2007    Scaling parameter added

% try 
%     pictures = evalin('base', 'bitmaps');
%     if (class(pictures) == 'bitmap')
%        fprintf('Using images which are currently available in working memory\n');
%        return;
%     else
%         fprintf('Found bitmaps in working memory, but unknown type');
%     end;
% catch    
%         fprintf('No images currently available in working memory\n');
% end;

%resizeTo = [];
%resizeTo = [300 300];
%resizeTo = [500 500];

if nargin > 1
    resizeTo = scaling;    
else
    resizeTo = [];
end
   
if nargin < 3
    recursive = false;
end;

%bitmap_path = '/Users/justvanes/Documents/JanBernard/SaliencyExperiment/stimuli/';
if nargin == 0
    bitmap_path =  FunctionFolder(mfilename)
end;

if (strcmp(  bitmap_path ( length(bitmap_path) ), '/' ) == 0)
   bitmap_path = [bitmap_path '/'];
end

    
if strcmp('recursive', recursive)
     recursive = true;
end

if resizeTo == 1
    resizeTo = [];
end;

files = dir(bitmap_path)

fprintf('Loading image database from:\n');
bitmap_path
fprintf('One moment please...\n');

    
max_bitmap = -1;
index = 1;
pictures = bitmap;

size(files,1);

for f = 1:size(files, 1)
     if isImage( [bitmap_path files(f).name])
        fprintf('reading file : %s\n', files(f).name);
        bitmap_filename = [ bitmap_path files(f).name ];
        current_bitmap = bitmap;
        current_bitmap = set(current_bitmap, 'filename', bitmap_filename);
    
        %try
          if (~isempty(resizeTo))
              % perform bitmap resize to the size size on the fly
  
              if (size(resizeTo, 2) == 2) %% width and height given
                  current_bitmap = set(current_bitmap, 'data', imresize(imread(bitmap_filename), resizeTo, 'bilinear'));
              else %% factor to 
                  raw = imread(bitmap_filename);
                  resizeTo = size(raw) * resizeTo;
                  current_bitmap = set(current_bitmap, 'data', imresize(raw, resizeTo, 'bilinear'));
              end
          else
              current_bitmap = set(current_bitmap, 'data', imread(bitmap_filename));
          end;
          
        %catch
        %  lasterr;
        %  fprintf('Error occurred while reading :\n');
        %  fprintf('Filename : %s\n', bitmap_filename);

        %end;
        fprintf('%d..', index);
        current_bitmap = set(current_bitmap, 'name', files(f).name);
        current_bitmap = set(current_bitmap, 'path', bitmap_path);
        
        pictures(index) = current_bitmap;
        
        index = index +1;
     end;

     if ((files(f).isdir) && recursive)         
         if (~((strcmp(files(f).name, '.') | strcmp(files(f).name, '..'))))
             subdir_pictures = load_bitmaps( [bitmap_path files(f).name], resizeTo, 'recursive' );
             number = size(subdir_pictures, 2);
               
             fprintf('appending to pics @ index : %d\n', index);
             pictures(index: index + number -1 ) = subdir_pictures;
             index = index + number;   
             if (number ==1 && isempty(get(subdir_pictures(1), 'data')))
                 index = index +1;
             end
         end
     end;

    
    if (index == max_bitmap+1)
        break
    end;
 end;
assignin('base', 'bitmaps',pictures);

fprintf('Done loading pictures...\n');
