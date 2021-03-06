# analyze survey data for free (http://asdfree.com) with the r language
# home mortgage disclosure act
# 2006 - 2012 files

# # # # # # # # # # # # # # # # #
# # block of code to run this # #
# # # # # # # # # # # # # # # # #
# library(downloader)
# setwd( "C:/My Directory/HMDA/" )
# years.to.download <- 2012:2006
# source_url( "https://raw.github.com/ajdamico/usgsd/master/Home%20Mortgage%20Disclosure%20Act/download%20all%20microdata.R" , prompt = FALSE , echo = TRUE )
# # # # # # # # # # # # # # #
# # end of auto-run block # #
# # # # # # # # # # # # # # #

# if you have never used the r language before,
# watch this two minute video i made outlining
# how to run this script from start to finish
# http://www.screenr.com/Zpd8

# anthony joseph damico
# ajdamico@gmail.com

# if you use this script for a project, please send me a note
# it's always nice to hear about how people are using this stuff

# for further reading on cross-package comparisons, see:
# http://journal.r-project.org/archive/2009-2/RJournal_2009-2_Damico.pdf


##################################################################################
# download all 2006 - 2012 microdata for the home mortgage disclosure act with R #
##################################################################################



# # # # # # # # # # # # # # #
# warning: monetdb required #
# # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
###################################################################################################################################
# prior to running this analysis script, monetdb must be installed on the local machine.  follow each step outlined on this page: #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# https://github.com/ajdamico/usgsd/blob/master/MonetDB/monetdb%20installation%20instructions.R                                   #
###################################################################################################################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #



# all 2006-2012 HMDA data files will be stored
# in a your current working directory
# use forward slashes instead of back slashes

# uncomment this line by removing the `#` at the front..
# setwd( "C:/My Directory/HMDA/" )

# remove the # in order to run this install.packages line only once
# install.packages( c( "SAScii" , "R.utils" , "MonetDB.R" , "downloader" ) )


# choose which hmda data sets to download
# uncomment this line to download all available data sets
# uncomment this line by removing the `#` at the front
# years.to.download <- 2012:2006
# if you have a big hard drive, hey why not download them all?

# remove the `#` in order to just download 2011
# years.to.download <- 2011


# no need to edit anything below this line #

# # # # # # # # #
# program start #
# # # # # # # # #



library(R.utils)		# load the R.utils package (counts the number of lines in a file quickly)
library(MonetDB.R)		# load the MonetDB.R package (connects r to a monet database)
library(downloader)		# downloads and then runs the source() function on scripts from github
library(SAScii) 		# load the SAScii package (imports ascii data with a SAS script)



# load the download.cache and related functions
# to prevent re-downloading of files once they've been downloaded.
source_url( 
	"https://raw.github.com/ajdamico/usgsd/master/Download%20Cache/download%20cache.R" , 
	prompt = FALSE , 
	echo = FALSE 
)


# load the read.SAScii.monetdb() function,
# which imports ASCII (fixed-width) data files directly into a monet database
# using only a SAS importation script
source_url( "https://raw.github.com/ajdamico/usgsd/master/MonetDB/read.SAScii.monetdb.R" , prompt = FALSE )

# create five temporary files and also a temporary directory on the local disk
tf <- tempfile() ; tf2 <- tempfile() ; tf3 <- tempfile() ; tf4 <- tempfile() ; tf5 <- tempfile() ; td <- tempdir()


# download the layout files for the loan applications received (lar) and institutional records (ins) data tables
download.cache( "https://raw.github.com/ajdamico/usgsd/master/Home%20Mortgage%20Disclosure%20Act/lar_str.csv" , tf , FUN = download )
download.cache( "https://raw.github.com/ajdamico/usgsd/master/Home%20Mortgage%20Disclosure%20Act/ins_str.csv" , tf2 , FUN = download )


# configure a monetdb database for the hmda on windows #

# note: only run this command once.  this creates an executable (.bat) file
# in the appropriate directory on your local disk.
# when adding new files or adding a new year of data, this script does not need to be re-run.

# create a monetdb executable (.bat) file for the home mortgage disclosure act data
batfile <-
	monetdb.server.setup(
					
					# set the path to the directory where the initialization batch file and all data will be stored
					database.directory = paste0( getwd() , "/MonetDB" ) ,
					# must be empty or not exist
					
					# find the main path to the monetdb installation program
					monetdb.program.path = "C:/Program Files/MonetDB/MonetDB5" ,
					
					# choose a database name
					dbname = "hmda" ,
					
					# choose a database port
					# this port should not conflict with other monetdb databases
					# on your local computer.  two databases with the same port number
					# cannot be accessed at the same time
					dbport = 50005
	)



# this next step is so very important.

# store a line of code that will make it easy to open up the monetdb server in the future.
# this should contain the same file path as the batfile created above,
# you're best bet is to actually look at your local disk to find the full filepath of the executable (.bat) file.
# if you ran this script without changes, the batfile will get stored in C:\My Directory\HMDA\MonetDB\hmda.bat

# here's the batfile location:
batfile

# note that since you only run the `monetdb.server.setup()` function the first time this script is run,
# you will need to note the location of the batfile for future MonetDB analyses!

# in future R sessions, you can create the batfile variable with a line like..
# batfile <- "C:/My Directory/HMDA/MonetDB/hmda.bat"
# obviously, without the `#` comment character

# hold on to that line for future scripts.
# you need to run this line *every time* you access
# the home mortgage disclosure act files with monetdb.
# this is the monetdb server.

# two other things you need: the database name and the database port.
# store them now for later in this script, but hold on to them for other scripts as well
dbname <- "hmda"
dbport <- 50005

# now the local windows machine contains a new executable program at "c:\my directory\hmda\monetdb\hmda.bat"

# end of monetdb database configuration #


# it's recommended that after you've _created_ the monetdb server,
# you create a block of code like the one below to _access_ the monetdb server


#####################################################################
# lines of code to hold on to for all other `hmda` monetdb analyses #

# first: specify your batfile.  again, mine looks like this:
# uncomment this line by removing the `#` at the front..
# batfile <- "C:/My Directory/HMDA/MonetDB/hmda.bat"

# second: run the MonetDB server
pid <- monetdb.server.start( batfile )

# third: your six lines to make a monet database connection.
# just like above, mine look like this:
dbname <- "hmda"
dbport <- 50005

monet.url <- paste0( "monetdb://localhost:" , dbport , "/" , dbname )
db <- dbConnect( MonetDB.R() , monet.url , wait = TRUE )



# # # # run your analysis commands # # # #


# read in the loan application record structure file
lar_str <- read.csv( tf )
# paste all rows together into single strings
lar_col <- apply( lar_str , 1 , paste , collapse = " " )

# take a look at the `lar_str` and `lar_col` objects if you're curious
# just type 'em into the console to see what i mean ;)

# read in the loan application record structure file
ins_str <- read.csv( tf2 )
# paste all rows together into single strings
ins_col <- apply( ins_str , 1 , paste , collapse = " " )


# create an msa office sas importation script..
office.lines <- 
	"INPUT
	AS_OF_YEAR 4
	Agency_Code $ 1
	Respondent_ID $ 10
	MSA_MD $ 5
	MSA_MD_Description $ 50 
	;"
	
# ..save it to the local disk as a temporary file..
writeLines( office.lines , tf4 )

# ..and save the column names into a new object `office.names`
office.names <- tolower( parse.SAScii( tf4 )$varname )


# loop through each of the years to download..
for ( year in substr( years.to.download , 3 , 4 ) ){

	# loop through both the public (hmda) and private (pmic) data files..
	for ( pubpriv in c( 'hmda' , 'pmic' ) ){

		# reporter panel, msa_md with home, msa office do not exist in 2006, so skip it.
		if ( as.numeric( year ) > 6 ){

			# reporter panel read-in
			
			# the 2007, 2008, and 2009 reporter panel sas importation scripts are different from post-2009
			if ( as.numeric( year ) < 10 ){
				sas_ri <- "https://raw.github.com/ajdamico/usgsd/master/Home%20Mortgage%20Disclosure%20Act/Reporter%20Panel%20Pre-2010.sas"
			} else {
				sas_ri <- "https://raw.github.com/ajdamico/usgsd/master/Home%20Mortgage%20Disclosure%20Act/Reporter%20Panel%202010.sas"
			}
		
			# download the sas importation instructions to a temporary file on the local disk
			download.cache( sas_ri , tf3 , FUN = download )


			# construct the url of the current `ReporterPanel.zip` to download
			fn <- paste0( "http://www.ffiec.gov/" , pubpriv , "rawdata/OTHER/20" , year , pubpriv , "ReporterPanel.zip" )

			
			# read that temporary file directly into MonetDB,
			# using only the sas importation script
			read.SAScii.monetdb (
				fn ,			# the url of the file to download
				tf3 ,			# the 
				zipped = T ,	# the ascii file is stored in a zipped file
				tl = TRUE ,		# convert all column names to lowercase
				tablename = paste( pubpriv , 'rep' , year , sep = "_" ) ,
				connection = db
			)

			# construct the url of the current `MSAOffice.zip`
			fn <- paste0( "http://www.ffiec.gov/" , pubpriv , "rawdata/OTHER/20" , year , pubpriv , "MSAOffice.zip" )
			
			# download that file..
			download.cache( fn , tf5 , mode = 'wb' )
			
			# ..and extract it to the temporary directory
			z <- unzip( tf5 , exdir = td )
			
			# read the entire file into RAM
			msa_ofc <-
				read.table(
					z ,
					header = FALSE ,
					quote = "\"" ,
					sep = '\t' ,
					# ..using the `office.names` extracted from the code above
					col.names = office.names
				)
				
			# write the `msa` table into the database directly
			dbWriteTable( db , paste( pubpriv , 'msa' , year , sep = "_" ) , msa_ofc )
			
			# remove the table from memory
			rm( msa_ofc )
			
			# clear up RAM
			gc()
			
		}
		
		# cycle through both institutional records and loan applications received microdata files
		for ( rectype in c( "institutionrecords" , "lar%20-%20National" ) ){

			# strip just the first three characters from `rectype`
			short.name <- substr( rectype , 1 , 3 )
		
			# construct a tablename.  for example: hmda_lar_11
			tablename <- paste( pubpriv , short.name , year , sep = "_" )
			
			# pull the structure construction
			col_str <- get( paste( short.name , "col" , sep = "_" ) )
			
			# design the monetdb table
			sql.create <- sprintf( paste( "CREATE TABLE" , tablename , "(%s)" ) , paste( col_str , collapse = ", " ) )

			# initiate the monetdb table
			dbSendUpdate( db , sql.create )

			# find the url folder and the appropriate delimiter line for the monetdb COPY INTO command
			if ( short.name == "lar" ){
			
				folder <- "LAR/National"
				delim.line <- "' using delimiters ',','\\n','\"' NULL AS ''" 
				
			} else {
			
				folder <- "OTHER"
				delim.line <- "' using delimiters '\\t' NULL AS ''" 
			
			}
						
			# construct the full url path of the file to download
			fn <- paste0( "http://www.ffiec.gov/" , pubpriv , "rawdata/" , folder , "/20" , year , pubpriv , rectype , ".zip" )

			# download the url into a temporary file on your local disk
			download.cache( fn , tf , mode = 'wb' )

			# unzip the csv file
			csv.file <- unzip( tf , exdir = td )

			# construct the monetdb COPY INTO command
			sql.copy <- 
				paste0( 
					"copy " , 
					countLines( csv.file ) , 
					" records into " , 
					tablename , 
					" from '" , 
					normalizePath( csv.file ) , 
					delim.line
				)
				
			# actually execute the COPY INTO command
			dbSendUpdate( db , sql.copy )
		
			# conversion of numeric columns incorrectly stored as character strings #
		
			# initiate a character vector containing all columns that should be numeric types
			revision.variables <- c( "sequencenumber" , "population" , "minoritypopulationpct" , "hudmedianfamilyincome" , "tracttomsa_mdincomepct" , "numberofowneroccupiedunits" , "numberof1to4familyunits" )

			# determine whether any of those variables are in the current table
			field.revisions <- dbListFields( db , tablename )[ tolower( dbListFields( db , tablename ) ) %in% revision.variables ]

			# loop through each of those variables
			for ( col.rev in field.revisions ){

				# add a new `temp_double` column in the data table
				dbSendUpdate( db , paste( "ALTER TABLE" , tablename , "ADD COLUMN temp_double DOUBLE" ) )

				# copy over the contents of the character-typed column so long as the column isn't a textual missing
				dbSendUpdate( db , paste( "UPDATE" , tablename , "SET temp_double = CAST(" , col.rev , " AS DOUBLE ) WHERE NOT ( " , col.rev , " = 'NA    ' ) AND NOT ( " , col.rev , " = 'NA      ' )" ) )
				
				# remove the character-typed column from the data table
				dbSendUpdate( db , paste( "ALTER TABLE" , tablename , "DROP COLUMN" , col.rev ) )
				
				# re-initiate the same column name, but as a numeric type
				dbSendUpdate( db , paste( "ALTER TABLE" , tablename , "ADD COLUMN" , col.rev , "DOUBLE" ) )
				
				# copy the corrected contents back to the original column name
				dbSendUpdate( db , paste( "UPDATE" , tablename , "SET" , col.rev , "= temp_double" ) )
				
				# remove the temporary column from the data table
				dbSendUpdate( db , paste( "ALTER TABLE" , tablename , "DROP COLUMN temp_double" ) )

			}

			# end of conversion of numeric columns incorrectly stored as character strings #

		}
		
		# now that all files have been imported for this hmda/pmic combination,
		# merge the lar and institution records for quicker access to lender information
		
		lar.tablename <- paste( pubpriv , 'lar' , year , sep = "_" )
		ins.tablename <- paste( pubpriv , 'ins' , year , sep = "_" )
		new.tablename <- paste( pubpriv , year , sep = "_" )
		
		# three easy steps #
		
		# step one: confirm the only intersecting fields are "respondentid" and "agencycode"
		# these are the merge fields, so nothing else can overlap
		
		stopifnot( 
			identical( 
				intersect( 
					dbListFields( db , lar.tablename ) , 
					dbListFields( db , ins.tablename ) 
				) , 
				c( 'respondentid' , 'agencycode' ) 
			) 
		)
		
		# step two: merge the two tables
		
		# extract the column names from the institution table
		ins.fields <- dbListFields( db , ins.tablename )
		
		# throw out the two merge fields
		ins.nomatch <- ins.fields[ !( ins.fields %in% c( 'respondentid' , 'agencycode' ) ) ]
		
		# add a "b." in front of every field name
		ins.b <- paste0( "b." , ins.nomatch )
		
		# separate all of them by commas into a single character string
		ins.string <- paste( ins.b , collapse = ", " )
		
		# construct the merge command
		sql.merge.command <-
			paste(
				"CREATE TABLE" , 
				new.tablename ,
				"AS SELECT a.* ," ,
				ins.string ,
				"FROM" ,
				lar.tablename ,
				"AS a INNER JOIN" ,
				ins.tablename ,
				"AS b ON a.respondentid = b.respondentid AND a.agencycode = b.agencycode WITH DATA"
			)
		
		# with your sql string built, execute the command
		dbSendUpdate( db , sql.merge.command )
		
		# step three: confirm that the merged table contains the same record count
		stopifnot( 
			dbGetQuery( 
				db , 
				paste(
					'select count(*) from' ,
					new.tablename
				)
			) ==
			dbGetQuery( 
				db , 
				paste(
					'select count(*) from' ,
					lar.tablename
				)
			)
		)

		# # # # # # # # # # # # # # # # # #
		# # race and ethnicity recoding # #
		# # # # # # # # # # # # # # # # # #
		
		# number of minority races of applicant and co-applicant
		dbSendUpdate( db , paste( 'ALTER TABLE' , new.tablename , 'ADD COLUMN app_min_cnt INTEGER' ) )
		dbSendUpdate( db , paste( 'ALTER TABLE' , new.tablename , 'ADD COLUMN co_min_cnt INTEGER' ) )

		# sum up all four possibilities
		dbSendUpdate( 
			db , 
			paste(
				'UPDATE' ,
				new.tablename ,
				'SET 
					app_min_cnt = 
					(
						( applicantrace1 IN ( 1 , 2 , 3 , 4 ) )*1 +
						( applicantrace2 IN ( 1 , 2 , 3 , 4 ) )*1 +
						( applicantrace3 IN ( 1 , 2 , 3 , 4 ) )*1 +
						( applicantrace4 IN ( 1 , 2 , 3 , 4 ) )*1 +
						( applicantrace5 IN ( 1 , 2 , 3 , 4 ) )*1
					)' 
			)
		)

		# same for the co-applicant
		dbSendUpdate( 
			db , 
			paste(
				'UPDATE' ,
				new.tablename , 
				'SET 
					co_min_cnt = 
					(
						( coapplicantrace1 IN ( 1 , 2 , 3 , 4 ) )*1 +
						( coapplicantrace2 IN ( 1 , 2 , 3 , 4 ) )*1 +
						( coapplicantrace3 IN ( 1 , 2 , 3 , 4 ) )*1 +
						( coapplicantrace4 IN ( 1 , 2 , 3 , 4 ) )*1 +
						( coapplicantrace5 IN ( 1 , 2 , 3 , 4 ) )*1
					)' 
			)
		)

		# zero-one test of whether the applicant or co-applicant indicated white
		dbSendUpdate( db , paste( 'ALTER TABLE' , new.tablename , 'ADD COLUMN appwhite INTEGER' ) )
		dbSendUpdate( db , paste( 'ALTER TABLE' , new.tablename , 'ADD COLUMN cowhite INTEGER' ) )

		# check all five race categories for the answer
		dbSendUpdate( 
			db , 
			paste(
				'UPDATE' ,
				new.tablename , 
				'SET 
					appwhite = 
					( 
						( ( applicantrace1 ) IN ( 5 ) )*1 + 
						( ( applicantrace2 ) IN ( 5 ) )*1 + 
						( ( applicantrace3 ) IN ( 5 ) )*1 + 
						( ( applicantrace4 ) IN ( 5 ) )*1 + 
						( ( applicantrace5 ) IN ( 5 ) )*1 
					)' 
			)
		)

		# same for the co-applicant
		dbSendUpdate( 
			db , 
			paste(
				'UPDATE' ,
				new.tablename ,
				'SET 
					cowhite = 
					( 
						( ( coapplicantrace1 ) IN ( 5 ) )*1 + 
						( ( coapplicantrace2 ) IN ( 5 ) )*1 + 
						( ( coapplicantrace3 ) IN ( 5 ) )*1 + 
						( ( coapplicantrace4 ) IN ( 5 ) )*1 + 
						( ( coapplicantrace5 ) IN ( 5 ) )*1 
					)' 
			)
		)

		# if the applicant or co-applicant has a missing first race, set the above variables to missing as well
		dbSendUpdate( db , paste( 'UPDATE' , new.tablename , 'SET app_min_cnt = NULL WHERE applicantrace1 IN ( 6 , 7 )' ) )
		dbSendUpdate( db , paste( 'UPDATE' , new.tablename , 'SET appwhite = NULL WHERE applicantrace1 IN ( 6 , 7 )' ) )
		dbSendUpdate( db , paste( 'UPDATE' , new.tablename , 'SET co_min_cnt = NULL WHERE coapplicantrace1 IN ( 6 , 7 , 8 )' ) )
		dbSendUpdate( db , paste( 'UPDATE' , new.tablename , 'SET cowhite = NULL WHERE coapplicantrace1 IN ( 6 , 7 , 8 )' ) )

		# main race variable
		dbSendUpdate( db , paste( 'ALTER TABLE' , new.tablename , 'ADD COLUMN race INTEGER' ) )

		# 7 indicates a loan by a white applicant and non-white co-applicant or vice-versa
		dbSendUpdate( db , paste( 'UPDATE' , new.tablename , 'SET race = 7 WHERE ( appwhite = 1 AND app_min_cnt = 0 AND co_min_cnt > 0 ) OR ( cowhite = 1 AND co_min_cnt = 0 AND app_min_cnt > 0 )' ) )

		# 6 indicates the main applicant listed multiple non-white races
		dbSendUpdate( db , paste( 'UPDATE' , new.tablename , 'SET race = 6 WHERE ( app_min_cnt > 1 ) AND ( race IS NULL )' ) )

		# for everybody else: if the first race listed by the applicant isn't white, use that.
		dbSendUpdate( db , paste( "UPDATE" , new.tablename , "SET race = applicantrace1 WHERE ( applicantrace1 IN ( '1' , '2' , '3' , '4' ) ) AND ( app_min_cnt = 1 ) AND ( race IS NULL )" ) )
		# otherwise look to the second listed race
		dbSendUpdate( db , paste( "UPDATE" , new.tablename , "SET race = applicantrace2 WHERE ( applicantrace2 IN ( '1' , '2' , '3' , '4' ) ) AND ( app_min_cnt = 1 ) AND ( race IS NULL )" ) )
		# otherwise confirm the applicant indicated he or she was white
		dbSendUpdate( db , paste( 'UPDATE' , new.tablename , "SET race = 5 WHERE ( appwhite = 1 ) AND ( race IS NULL )" ) )

		# main ethnicity variable
		dbSendUpdate( db , paste( 'ALTER TABLE' , new.tablename , 'ADD COLUMN ethnicity VARCHAR (255)' ) )

		# simple.  check the applicant's ethnicity
		dbSendUpdate( db , paste( "UPDATE" , new.tablename , "SET ethnicity = 'Not Hispanic' WHERE applicantethnicity IN ( 2 )" ) )
		
		# simple.  check the applicant's ethnicity again
		dbSendUpdate( db , paste( "UPDATE" , new.tablename , "SET ethnicity = 'Hispanic' WHERE applicantethnicity IN ( 1 )" ) )
		
		# overwrite the ethnicity variable if the main applicant indicates hispanic but the co-applicant does not.  or vice versa.
		dbSendUpdate( db , paste( "UPDATE" , new.tablename , "SET ethnicity = 'Joint' WHERE ( applicantethnicity IN ( 1 ) AND coapplicantethnicity IN ( 2 ) ) OR ( applicantethnicity IN ( 2 ) AND coapplicantethnicity IN ( 1 ) )" ) )

		# # # # # # # # # # # # # # # # # # # # # # # # #
		# # finished with race and ethnicity recoding # #
		# # # # # # # # # # # # # # # # # # # # # # # # #
		
		# in general, use this new tablename for all your analyses,
		# since it's got institutional information already merged
		print( paste( new.tablename , "finito!" ) )
		
	}
	
}

# remove all files on your local disk
file.remove( tf , tf2 , tf3 , tf4 , tf5 , z , csv.file )



# the current working directory should now contain a MonetDB folder
# with all of the hmda contents of each year downloaded


# once complete, this script does not need to be run again.


# the current monet database should now contain
# all of the newly-added tables (in addition to meta-data tables)
dbListTables( db )		# print the tables stored in the current monet database to the screen


# disconnect from the current monet database
dbDisconnect( db )

# and close it using the `pid`
monetdb.server.stop( pid )




#####################################################################
# lines of code to hold on to for all other `hmda` monetdb analyses #

# first: specify your batfile.  again, mine looks like this:
# uncomment this line by removing the `#` at the front..
# batfile <- "C:/My Directory/HMDA/MonetDB/brfss.bat"

# second: run the MonetDB server
pid <- monetdb.server.start( batfile )

# third: your five lines to make a monet database connection.
# just like above, mine look like this:
dbname <- "hmda"
dbport <- 50005

monet.url <- paste0( "monetdb://localhost:" , dbport , "/" , dbname )
db <- dbConnect( MonetDB.R() , monet.url , wait = TRUE )


# # # # run your analysis commands # # # #


# disconnect from the current monet database
dbDisconnect( db )

# and close it using the `pid`
monetdb.server.stop( pid )

# end of lines of code to hold on to for all other `hmda` monetdb analyses #
############################################################################


# unlike most post-importation scripts, the monetdb directory cannot be set to read-only #
message( paste( "all done.  DO NOT set" , getwd() , "read-only or subsequent scripts will not work." ) )

message( "got that? monetdb directories should not be set read-only." )


# for more details on how to work with data in r
# check out my two minute tutorial video site
# http://www.twotorials.com/

# dear everyone: please contribute your script.
# have you written syntax that precisely matches an official publication?
message( "if others might benefit, send your code to ajdamico@gmail.com" )
# http://asdfree.com needs more user contributions

# let's play the which one of these things doesn't belong game:
# "only you can prevent forest fires" -smokey bear
# "take a bite out of crime" -mcgruff the crime pooch
# "plz gimme your statistical programming" -anthony damico
