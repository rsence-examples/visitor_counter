##   
 #   Copyright 2010 Riassence Inc.
 #   http://riassence.com/
 #
 #   You should have received a copy of the GNU Lesser General Public License
 #   along with this software package. If not, contact licensing@riassence.com
 ##
 
# = Visitor Counter
# Real time visitor counter example showing usage of selected server events. 
# Please refer to server side documentation for full list of events.
#
# Please refer to rdoc of rsence gem for full server side documentation.
# 
# Feel free to join #rsence on the IRCnet and FreeNode networks for further 
# questions.

class VisitorCounter < GUIPlugin
attr_reader :hits_total, :visits_total, :visits_unique
  # Called once when the plugin is loaded
  def open
    super
    # Total number of messages between clients and the server
    @hits_total = 0
    # Total number of visits
    @visits_total = 0
    # Total number of unique visits
    @visits_unique = 0
  end
  
  # Runs every time during the value synchronization (every time the client connects)
  def idle( msg )
    super( msg )
    @hits_total += 1
    ses = get_ses( msg )
    # Sets all the values which might have changed on the server
    # A note about the set method below:
    # It is safe to use #set without the fear of overhead
    # RSence checks automatically if the value stored in 
    # msg (session) is the same
    ses[:total_hits].set( msg, @hits_total )
    ses[:total_visits].set( msg, @visits_total )
    ses[:unique_visits].set( msg, @visits_unique )
  end
  
  # Restore session will be invoked when an old session in client is detected
  def restore_ses( msg )
    super( msg )
    @visits_total += 1
    ses = get_ses( msg )
    ses[:total_visits].set( msg, @visits_total )
    add_session_visit( msg )
  end
  
  # Session initialization, whenever a new client is detected this method will be invoked
  def init_ses( msg )
    super( msg )
    @visits_total += 1
    @visits_unique += 1
    add_session_visit( msg )
  end
  
  # Value initialization method, see values.yaml for details
  def session_visits( msg )
    ses = get_ses( msg )
    puts ses[:session_visits]
    if (ses[:session_visits] == nil)
      return 0
    else
      return ses[:session_visits].data
    end
  end
  
  # A helper method to add +1 for :session_visits
  def add_session_visit( msg )
    ses = get_ses( msg )
    visits = ses[:session_visits].data
    puts "session visits: #{visits}"
    visits += 1
    ses[:session_visits].set( msg, visits )
    
  end

end 