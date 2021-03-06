require 'colorize'
require 'rgl/adjacency'
require 'rgl/dot'

# node class representing single node-task in graph
class Node
  attr_accessor :task, :proc_time, :prev_tasks, :next_tasks, :color,
                :level, :count

  # init new node
  def initialize(task, proc_t, prev_t, next_t)
    # data that is read from file
    @task       = task            # task index/number
    @proc_time  = proc_t          # time of task execution/processing
    @prev_tasks = prev_t          # array of tasks right before
    @next_tasks = next_t          # array of tasks right after
    # data modified in hu algorithm
    @color      = 'r'             # color of task, describes the state of it
                                    # g(reen) => exists in system
                                    # r(ed)   => outside of system
                                    # w(hite) => finished
    @level      = 0               # level of task (distance from root)
    @count      = 0               # helper in in-tree checking
  end
end

# copy values of nodes
def copy_nodes(graph)
  new_nodes = []
  graph.nodes.each do |node|
    # get old values
    copy_node = Node.new(node.task, node.proc_time, \
                         node.prev_tasks, node.next_tasks)
    # maybe copy color and level too
    new_nodes << copy_node
  end
  # return copied values
  return new_nodes
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
  end

  # add count in in-tree checking
  def add_count_to_task(task_index)
    @nodes.each do |node|
      if node.task == task_index
        node.count += 1
        # return duplicate "error"
        return 1 if node.count > 1
        # else return 0
        return 0
      end
    end
    raise ArgumentError, "Node with task number #{task_index} does not exists!" \
  end

  # loading graph from file
  def load_from_file(filename)
    File.readlines(filename).each do |line|
      # miss me with that windows format
      line.gsub!(/\r\n?/, "\n")
      # first split by space
      line = line.split(' ')
      raise ArgumentError, 'Missing some input data!' \
        if line.length != 4
      # now split every part of line
      task = line[0].split(':')
      raise ArgumentError, 'Wrong task index data!' \
        if task.length != 2 || task[0] != 'n'
      task = task[1].to_i

      proc_t = line[1].split(':')
      raise ArgumentError, 'Wrong processing time data!' \
        if proc_t.length != 2 || proc_t[0] != 'p' || proc_t[1] != '1'
      proc_t = proc_t[1].to_i

      prev_t = line[2].split(':')
      raise ArgumentError, 'Wrong previous tasks data!' \
        if prev_t[0] != 'prev'
      prev_t = prev_t.drop(1).map(&:to_i)

      next_t = line[3].split(':')
      raise ArgumentError, 'Wrong next tasks data!' \
        if next_t[0] != 'next'
      next_t = next_t.drop(1).map(&:to_i)

      created_node = Node.new(task, proc_t, prev_t, next_t)
      @nodes << created_node
    end
  end

  # pretty prints graph data
  def print_graph_data(c_max)
    puts "-------------------------------------".light_yellow
    puts "------------ Graph data -------------".light_yellow.on_red
    @nodes.each do |node|
      puts "-------------------------------------".light_yellow
      print ("task: " + node.task.to_s).light_red
      print " p: " + node.proc_time.to_s
      print " color: " + node.color
      print "\nprev: "
      print node.prev_tasks
      print " next: "
      print node.next_tasks
      print ("\nlevel: " + node.level.to_s).light_cyan
      puts "\n-------------------------------------".light_yellow
    end
    puts "## More graph/tasks data:".light_yellow.on_red
    puts "## Cmax = #{c_max}".light_cyan
    puts "## For timetable check output folder.".green
    puts "## File is named after argument file.".green
    puts "-------------------------------------".light_yellow
  end

  def pretty_name(node)
    new_name = "\nZ" + node.task.to_s + "\nlevel: " + node.level.to_s
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
