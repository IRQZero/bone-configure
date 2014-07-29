## the marrow washing classic

## booting up:
## check if ssh works and the bone_configure repo has new commits
HAS_REPO_ACCESS = false
if ssh github.com ; then
	# we can connect
	$HAS_REPO_ACCESS=true
else
	printf '%s\n' 'could not connect, checking for credentials \n' >&2
	if [!ls /root/.ssh/irq_rsa] ; then
		printf '%s\n' 'could not find private key in .ssh \n' >&2
	else
		if[]
fi

if $HAS_REPO_ACCESS ; then
	cd /var/lib/cloud9/javascript/ mixpanel
	
	git pull origin master



## capemanager overlay file in place 
cape_enable=capemgr.enable_partno=BB-UARTO1

cape_enable=capemgr.enable_partno=BB-BONE-AUDI-02
