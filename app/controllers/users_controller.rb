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
		@versions = Version.find(:all, :conditions=>["whodunnit = ?", @user.id])
		@versions.sort!{|a,b| b.created_at <=> a.created_at}
		#@versions=@versions[0..6]
	
		@activities=[]	
		@versions.each do |version|
			activity={}
			case version.event
				when 'create'
					case version.item_type
						when 'Issue' then activity[:action]='created a new'
						when 'Relationship' then activity[:action]='linked a new'
						when 'Reference' then activity[:action]='added a new'
					end 
				when 'update' then activity[:action]='updated the'
				when 'destroy' then activity[:action]='deleted the'
				else
					activity[:action]='?'
			end
			activity[:type]=version.item_type.downcase
			case version.item_type
				when 'Issue' then activity[:what]=version.get_object.title.to_s
				when 'Relationship'
					activity[:what]=Version.find(:all, :conditions=>['item_type=? AND item_id=?', 'Issue', version.get_object.issue_id]).first.get_object.title+' - '+Version.find(:all, :conditions=>['item_type=? AND item_id=?', 'Issue', version.get_object.cause_id]).first.get_object.title
				when 'Reference'
					(rel= Version.find(:all, :conditions=>["item_type=? AND item_id=?", 'Relationship', version.get_object.relationship_id]).first.get_object)
					activity[:what]='for relationship '+(Version.find(:all, :conditions=>['item_type=? AND item_id=?', 'Issue', rel.issue_id]).first.get_object.title+' - '+Version.find(:all, :conditions=>['item_type=? AND item_id=?', 'Issue', rel.cause_id]).first.get_object.title)
			end
			activity[:score]=RepManagement::Utils.reputation(:action=>version.event.downcase.to_sym, :type=>version.item_type.downcase.to_sym, :id=>version.item_id.to_i, :me=>version.whodunnit.to_i, :you=>version.get_object.user_id.to_i, :calculate=>false)[0]
			@activities << activity
		end



    respond_to do |format|
      format.html # show.html.erb
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

	def activities
		@user = User.find(params[:id])
		@issues = []
		@relationships = []
		@references = []

		@activities = Version.find(:all, :conditions=>["whodunnit = ?", @user.id])
		@activities.sort!{|a,b| b.created_at <=> a.created_at}
		@activities = @activities.paginate(:page => params[:page], :per_page => 10)
		
		#@activities.each do |activity|

			#parameters={}
			#!activity.event.eql?('update') ? parameters[:action] = activite.event.downcase.to_sym : nil
			#['Relationship', 'Issue', 'Reference'].include?(activity.item_type) ? parameters[:type] = activity.item_type.downcase.to_sym : nil
			#@user == activity.get_object.user ? parameters[:owned] = true : parameters[:owned] = false
			#if activity.item_type.eql?('Relationship')
			#	relationship = activity.get_object
			#	degree = 3
			#	[relationship.issue, relationship.cause].each do |issue|
			#			@user.issues.include?(issue) ? degree -= 1 : degree -= 0
			#	end
			#	parameters[:degree] = degree				
			#elsif activity.item_type.eql?('Reference')
			#	reference = activity.get_object				
			#end

			#case
			#	when activity.get_object.instance_of?(Issue) then @issues << activity
			#	when activity.get_object.instance_of?(Relationship) then @relationships << activity
			#	when activity.get_object.instance_of?(Reference) then @references << activity
			#end
		#end

		#if !@issues.empty?
		#	@issues.uniq.sort!{|a,b| b.created_at <=> a.created_at}
		#	@issues = @issues.paginate(:page => params[:page], :per_page => 10)
		#end
		#if !@relationships.empty?
		#	@relationships.uniq.sort!{|a,b| b.created_at <=> a.created_at}
		#	@relationships = @relationships.paginate(:page => params[:page], :per_page => 10)
		#end
		#if !@references.empty? 
		#	@references.uniq.sort!{|a,b| b.created_at <=> a.created_at}
		#	@references = @references.paginate(:page => params[:page], :per_page => 10)
		#end


		respond_to do |format|
      format.html 
      format.xml
    end
	end
end
