import org.eclipse.jgit.api._
import org.eclipse.jgit.lib._
import org.eclipse.jgit.revwalk._
import org.eclipse.jgit.treewalk._
import org.eclipse.jgit.treewalk.filter._
import org.eclipse.jgit.internal.storage.file._
import java.io._

import collection.JavaConversions._

object GitControl extends App {

  val repository = new FileRepository("./repo/.git")
  val git = new Git(repository)

  // val objectId = repository.resolve("47dfeedd8079086f05cb5216dc3b8ec334dae856")
  // val revwalk = new RevWalk(repository)
  // val commit = revwalk.parseCommit(objectId)
  // val treeWalk = new TreeWalk(repository)
  // treeWalk.addTree(commit.getTree)
  // treeWalk.setRecursive(true)
  // treeWalk.setFilter(PathFilter.create("hello"))
  // if (!treeWalk.next()) {
  //   throw new IllegalStateException("Did not find expected file 'README.md'");
  // }
  // val id = treeWalk.getObjectId(0)
  // println(new String(repository.open(id).getBytes))


  // val commits = git.log.addPath("hello").call.toSeq
  // commits.foreach { commit =>
  //   println(commit.getCommitTime)
  //   println(commit.getAuthorIdent.getName)
  //   println(commit.getAuthorIdent.getEmailAddress)
  //   println(commit.getFullMessage)
  //   println(commit.getName)
  //   println(commit.toString)

  //   val treeWalk = new TreeWalk(repository)
  //   treeWalk.addTree(commit.getTree)
  //   treeWalk.setRecursive(true)
  //   treeWalk.setFilter(PathFilter.create("hello"))
  //   if (!treeWalk.next()) {
  //     throw new IllegalStateException("Did not find expected file 'README.md'");
  //   }
  //   val id = treeWalk.getObjectId(0)
  //   println(new String(repository.open(id).getBytes))
  // }


  // val file = new PrintWriter("./repo/fuga")
  // val text = readLine
  // file.println(text)
  // file.close

  // git.add
  //   .addFilepattern(".")
  //   .call

  git.rm
    .addFilepattern("hoge")
    .call

  // git.commit
  //   .setMessage(s"add fuga")
  //   .setAuthor("1", "foo@bar.com")
  //   .setCommitter("foo", "foo@bar.com")
  //   .call

  git.close
}
