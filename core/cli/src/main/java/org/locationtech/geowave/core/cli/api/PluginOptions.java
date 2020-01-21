/**
 * Copyright (c) 2013-2019 Contributors to the Eclipse Foundation
 *
 * <p> See the NOTICE file distributed with this work for additional information regarding copyright
 * ownership. All rights reserved. This program and the accompanying materials are made available
 * under the terms of the Apache License, Version 2.0 which accompanies this distribution and is
 * available at http://www.apache.org/licenses/LICENSE-2.0.txt
 */
package org.locationtech.geowave.core.cli.api;

import java.util.Properties;

/** All plugins must provide this interface */
public interface PluginOptions {
  public String getType();

  public void selectPlugin(String qualifier);

  public void save(Properties properties, String namespace);

  public boolean load(Properties properties, String namespace);
}