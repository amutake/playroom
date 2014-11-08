import org.eclipse.jgit.api._
import org.eclipse.jgit.lib._
import org.eclipse.jgit.revwalk._
import org.eclipse.jgit.treewalk._
import org.eclipse.jgit.treewalk.filter._
import org.eclipse.jgit.internal.storage.file._
import org.eclipse.jgit.errors._
import java.io._

import collection.JavaConversions._

object GitControl extends App {

  val repository = new FileRepository("./repo/.git")
  val git = new Git(repository)

  def treeIter(hash: String) = {
    val oid = repository.resolve(hash)
    val walk = new RevWalk(repository)
    val commit = walk.parseCommit(oid)
    val treeParser = new CanonicalTreeParser()
    val reader = repository.newObjectReader
    treeParser.reset(reader, commit.getTree.getId)
    treeParser
  }

  def getContentFromId(filepath: String, commitId: String): Option[String] = {
    val objectId = repository.resolve(commitId)
    val commit = new RevWalk(repository).parseCommit(objectId)
    val walk = new TreeWalk(repository)
    walk.addTree(commit.getTree)
    walk.setRecursive(true)
    walk.setFilter(PathFilter.create(filepath))
    if (!walk.next()) {
      None
    } else {
      val id = walk.getObjectId(0)
      Some(new String(repository.open(id).getBytes))
    }
  }

  def getPreviousCommit(filepath: String, commitId: String): Option[RevCommit] = {
    val log = git.log
      .addPath(filepath)
      .call
    log.toSeq.map(_.getName).map(println _)
    log.headOption
  }

  def diffLastCommit(filepath: String, commitId: String): (Option[String], Option[String]) = {
    val objectId = repository.resolve(commitId)
    val commit = new RevWalk(repository).parseCommit(objectId)
    val parent = if (commit.getParentCount == 0) {
      None
    } else {
      Some(commit.getParent(0))
    }

    (getContentFromId(filepath, commitId), parent.flatMap(a => getContentFromId(filepath, a.getName)))
    // (content(commit), parent.flatMap(a => contentFromId(a.getName)))
  }

//  println(getContentFromId("GitControl.scala", "90688f057a402d27d2884999fc5d828e7a6b19ec"))

  // println(diffLastCommit("GitControl.scala", "d7a1170a1abc52b66de7f6912b339e31ac92f3e3"))

  getPreviousCommit("GitControl.scala", "90688f057a402d27d2884999fc5d828e7a6b19ec")

  val diffs = git.diff
    .setNewTree(treeIter("90688f057a402d27d2884999fc5d828e7a6b19ec"))
//    .setOldTree(treeIter("d7a1170a1abc52b66de7f6912b339e31ac92f3e3"))
//    .setPathFilter(PathFilter.create("hello"))
    .call

  diffs.foreach { d =>
    val oldId = d.getOldId.toObjectId
    val newId = d.getNewId.toObjectId

    def str(id: ObjectId) = try {
      Some(new String(repository.open(id).getBytes))
    } catch {
      case e: MissingObjectException => None
    }
    println("old:")
    println(str(oldId).getOrElse("error!"))

    println("new:")
    println(str(newId).getOrElse("error!"))
  }

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

  // git.rm
  //   .addFilepattern("hoge")
  //   .call

  // git.commit
  //   .setMessage(s"add fuga")
  //   .setAuthor("1", "foo@bar.com")
  //   .setCommitter("foo", "foo@bar.com")
  //   .call

  git.close
}
