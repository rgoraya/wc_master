class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    @userissues = @user.issues.search(params[:search]).order("created_at DESC").paginate(:per_page => 5, :page => params[:page])

		@versions = Version.find(:all, :conditions=>["whodunnit = ? AND reverted_from IS ? ", @user.id, nil])
		@versions.sort!{|a,b| b.created_at <=> a.created_at}
	
		@activities=[]	
		@versions.each do |version|
			activity={}
			case version.event
				when 'create'
					case version.item_type
						when 'Issue' then activity[:action]='created'
						when 'Relationship' then
							#if version.whodunnit.to_i == version.get_object.user_id.to_i
								activity[:action]='linked'
							#else
							#	activity[:action]='relinked'
							#end
						when 'Reference' then activity[:action]='added'
					end 
				when 'update' then activity[:action]='updated'
				when 'destroy' then activity[:action]='deleted'
				else
					activity[:action]='?'
			end
			activity[:type]=version.item_type.downcase
			activity[:what]=''
			begin
				case version.item_type
					when 'Issue' then activity[:what]=version.get_object.title.to_s
					when 'Relationship'
						activity[:what]= Version.find(:all, :conditions=>['item_type=? AND item_id=?', 'Issue', version.get_object.cause_id]).first.get_object.title + ' &#x27a1; ' + Version.find(:all, :conditions=>['item_type=? AND item_id=?', 'Issue', version.get_object.issue_id]).first.get_object.title
					when 'Reference'
						(rel= Version.find(:all, :conditions=>["item_type=? AND item_id=?", 'Relationship', version.get_object.relationship_id]).first.get_object)
						activity[:what]= Version.find(:all, :conditions=>['item_type=? AND item_id=?', 'Issue', rel.cause_id]).first.get_object.title + ' &#x27a1; ' + Version.find(:all, :conditions=>['item_type=? AND item_id=?', 'Issue', rel.issue_id]).first.get_object.title 
				end
			rescue
					activity[:what]='? <data untraceable>'				
			end
			activity[:time]=version.created_at
			version.get_object.user_id.nil? ? activity[:owner]=nil : activity[:owner]=version.get_object.user

			!activity[:what].include?('untraceable') ? activity[:score]=RepManagement::Utils.reputation(:action=>version.event.downcase.to_sym, :type=>version.item_type.downcase.to_sym, :id=>version.item_id.to_i, :me=>version.whodunnit.to_i, :you=>version.get_object.user_id.to_i, :undo=>false, :calculate=>false)[0] : activity[:score]=nil
			@activities << activity
		end


    respond_to do |format|
      format.js {render :layout=>false}
      format.html # index.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to(:issues, :notice => 'Registration successful.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(:issues, :notice => 'Successfully updated profile') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end
