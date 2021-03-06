require 'colorize'
require 'rgl/adjacency'
require 'rgl/dot'

# node class representing single node-task in graph
class Node
  attr_accessor :task, :proc_time, :due_time, :rev_time, :prev_tasks,
                :next_tasks, :mod_time, :color, :lateness, :pass_time

  # init new node
  def initialize(task, proc_t, due_t, rev_t, prev_t, next_t)
    # data that is read from file
    @task       = task            # task index/number
    @proc_time  = proc_t          # time of task execution/processing
    @due_time   = due_t           # time of due task execution
    @rev_time   = rev_t           # time of task reveal
    @prev_tasks = prev_t          # array of tasks right before
    @next_tasks = next_t          # array of tasks right after
    # data modified in liu algorithm
    @mod_time   = nil             # modified time of task's due time
    @color      = 'r'             # color of task, describes the state of it
                                    # g(reen) => exists in system
                                    # r(ed)   => outside of system
                                    # w(hite) => finished
    @lateness   = nil             # lateness of task
    @pass_time  = 0               # time that passed, task has been run for
  end
end

# mygraph class representing input in form of graph
class MyGraph
  attr_accessor :nodes

  # initialize with empty array of nodes
  def initialize
    @nodes = []
  end

  # search for node with given task index and return it
  def node_with_task(task_index)
    @nodes.each do |node|
      return node if node.task == task_index
    end
    raise ArgumentError, "Node with task number #{task_index} does not exists!" \
      if arr.empty?
  end

  # loading graph from file
  def load_from_file(filename)
    File.readlines(filename).each do |line|
      # miss me with that windows format
      line.gsub!(/\r\n?/, "\n")
      # first split by space
      line = line.split(' ')
      raise ArgumentError, 'Missing some input data!' \
        if line.length != 6
      # now split every part of line
      task = line[0].split(':')
      raise ArgumentError, 'Wrong task index data!' \
        if task.length != 2 || task[0] != 'n'
      task = task[1].to_i

      proc_t = line[1].split(':')
      raise ArgumentError, 'Wrong processing time data!' \
        if proc_t.length != 2 || proc_t[0] != 'p'
      proc_t = proc_t[1].to_i

      due_t = line[2].split(':')
      raise ArgumentError, 'Wrong due time data!' \
        if due_t.length != 2 || due_t[0] != 'd'
      due_t = due_t[1].to_i

      rev_t = line[3].split(':')
      raise ArgumentError, 'Wrong reveal time data!' \
        if rev_t.length != 2 || rev_t[0] != 'r'
      rev_t = rev_t[1].to_i

      prev_t = line[4].split(':')
      raise ArgumentError, 'Wrong previous tasks data!' \
        if prev_t[0] != 'prev'
      prev_t = prev_t.drop(1).map(&:to_i)

      next_t = line[5].split(':')
      raise ArgumentError, 'Wrong next tasks data!' \
        if next_t[0] != 'next'
      next_t = next_t.drop(1).map(&:to_i)

      created_node = Node.new(task, proc_t, due_t, rev_t, prev_t, next_t)
      @nodes << created_node
    end
  end

  # find max task lateness from graph data
  def find_max_lateness_in_graph_data()
    # L_max cannot be less than 0
    max_val = 0
    @nodes.each do |node|
      max_val = node.lateness if node.lateness > max_val
    end
    return max_val
  end

  # pretty prints graph data
  def print_graph_data(timetable_length)
    puts "-------------------------------------".light_yellow
    puts "------------ Graph data -------------".light_yellow.on_red
    @nodes.each do |node|
      puts "-------------------------------------".light_yellow
      print ("task: " + node.task.to_s).light_red
      print " p: " + node.proc_time.to_s + " d: " + node.due_time.to_s + " r: " +
           node.rev_time.to_s + "\n"
      print "prev: "
      print node.prev_tasks
      print " next: "
      print node.next_tasks
      print ("\nnew d: " + node.mod_time.to_s).light_cyan
      print (" L: " + node.lateness.to_s).light_cyan
      print " color: " + node.color
      puts "\n-------------------------------------".light_yellow
    end
    puts "## More graph/tasks data:".light_yellow.on_red
    puts "## time  = #{timetable_length}".light_cyan.blink
    puts "## Lmax* = #{find_max_lateness_in_graph_data()}".light_cyan
    puts "## For timetable check output folder.".green
    puts "## File is named after argument file.".green
    puts "-------------------------------------".light_yellow
  end

  def pretty_name(node)
    new_name = "\nZ" + node.task.to_s
  end

  def create_graph_jpg(filename)
    visualisation = RGL::DirectedAdjacencyGraph[]

    @nodes.each do |node|
      node_name = pretty_name(node)
      visualisation.add_vertex(node_name)
      if node.prev_tasks != nil
        node.prev_tasks.each do |dependent|
          @nodes.each do |find|
            if dependent == find.task
              dependent_name = pretty_name(find)
              visualisation.add_edge(dependent_name, node_name)
              break
            end
          end
        end
      end
    end

    visualisation.write_to_graphic_file('jpg', filename)
    # delete .dot file
    system("rm -f " + filename + ".dot")
  end
end
