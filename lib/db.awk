function queryDB( query            , row, i, cmd ) {
  gsub(/`/,"\\`",query);  # if writing directly, need: \\\`
  gsub(/\n/," ",query);
  gsub(/\ \ */," ",query);
  cmd = "/bin/echo -e \"" query "\" | mysql -u " DB_USER " -p" DB_PASS " -h " DB_HOST " -B --column-names " DB_NAME ;
  # print cmd;
  row = -1;
  inFS = FS; inRS = RS;
  FS = "\t"; RS = "\n";
  while ((cmd | getline ) > 0)
	{
	  row++;
	  if (row == 0) 
		{
		  DBQc = NF;
		  for (i = 1; i <= NF; i++)
			{
			  DBQf[i] = $i;
			}
		}
	  for (i = 1; i <= NF; i++)
		{
		  DBQ[row, DBQf[i]] = $i;
		}
	}
  close(cmd);
  DBQr = row;
  FS = inFS; RS = inFS;
}

function clearDBQ() {

  delete DBQ;
  delete DBQf;
  DBQr = 0;
  DBQc = 0;
}

function sendSQL( query            , cmd ) {
  gsub(/`/,"\\`",query);  # if writing directly, need: \\\`
  gsub(/\n/," ",query);
  gsub(/\ \ */," ",query);
  cmd = "/bin/echo -e \"" query "\" | mysql -u " DB_USER " -p" DB_PASS " -h " DB_HOST " " DB_NAME ;
  system(cmd)
}



