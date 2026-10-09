function git-get-emails --wraps=git\ log\ --format=\'\%an\ \<\%ae\>\'\ \|\ sort\ \|\ uniq --description alias\ git-get-emails=git\ log\ --format=\'\%an\ \<\%ae\>\'\ \|\ sort\ \|\ uniq
  git log --format='%an <%ae>' | sort | uniq $argv
        
end
