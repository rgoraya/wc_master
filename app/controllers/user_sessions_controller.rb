class UserSessionsController < ApplicationController
  # POST /user_sessions
  # POST /user_sessions.xml
  def create
    @user_session = UserSession.new(params[:user_session])

    respond_to do |format|
      if @user_session.save
        format.html { redirect_to(:back, :notice => 'Login successful') }
        format.xml  { render :xml => @user_session, :status => :created, :location => @user_session }
      else
        format.html { redirect_to(:back, :notice => @user_session.errors.full_messages.join(", ")) }
      end
    end
  end

  # PUT /user_sessions/1
  # PUT /user_sessions/1.xml
  def update
    @user_session = UserSession.find

    respond_to do |format|
      if @user_session.update_attributes(params[:user_session])
        format.html { redirect_to(@user_session, :notice => 'User session was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_session.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_sessions/1
  # DELETE /user_sessions/1.xml
  def destroy
    @user_session = UserSession.find
    @user_session.destroy

    respond_to do |format|
      format.html { redirect_to(:relationships, :notice => 'Logout successful') }
      format.xml  { head :ok }
    end
  end
end
